        SUBROUTINE LCMMAT (FAMI,KPG,KSP,COMP,MOD,IMAT,NMAT,
     &   ANGMAS,PGL,MATERD,MATERF, MATCST,NBCOMM,CPMONO,NDT,NDI,NR,NVI,
     &   HSR,NFS,NSG,TOUTMS,VIND,IMPEXP)
        IMPLICIT NONE
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 10/10/2011   AUTEUR PROIX J-M.PROIX 
C RESPONSABLE JMBHH01 J.M.PROIX
C TOLE CRP_21 CRS_1404
C ======================================================================
C COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.
C
C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.
C
C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C       ----------------------------------------------------------------
C       MONOCRISTAL : RECUPERATION DU MATERIAU A T(TEMPD) ET T+DT(TEMPF)
C                    NB DE CMP DIRECTES/CISAILLEMENT , NB VAR. INTERNES
C                    MATER(*,1) = E , NU , ALPHA
C                    MATER(*,2) = COEFFICIENT DE CHAQUE COMPORTEMENT
C                    VARIABLES INTERNES :
C                     EPSVP(6)+ALPHA,GAMMA,P PAR SYSTEME DE GLISSEMENT
C       ----------------------------------------------------------------
C       IN  FAMI   : FAMILLE DE POINT DE GAUSS
C            KPG   : NUMERO DU POINT DE GAUSS
C            KSP   : NUMERO DU SOUS-POINT DE GAUSS
C           COMP   :  GRANDEUR COMPOR
C           IMAT   :  ADRESSE DU MATERIAU CODE
C           MOD    :  TYPE DE MODELISATION
C           NMAT   :  DIMENSION  MAXIMUM DE MATER
C          ANGMAS  :  TROIS ANGLES DU MOT_CLEF MASSIF (AFFE_CARA_ELEM)
C       OUT MATERD :  COEFFICIENTS MATERIAU A T
C           PGL    : MATRICE DE PASSAGE GLOBAL LOCAL
C           MATERF :  COEFFICIENTS MATERIAU A T+DT
C                     MATER(*,1) = CARACTERISTIQUES   ELASTIQUES
C                     MATER(*,2) = CARACTERISTIQUES   PLASTIQUES
C           MATCST :  'OUI' SI  MATERIAU A T = MATERIAU A T+DT
C                     'NON' SINON
C           NBCOMM : POSITION DES COEF POUR CHAQUE LOI DE CHAQUE SYSTEME
C           CPMONO : NOMS DES LOIS POUR CHAQUE FAMILLE DE SYSTEME
C
C           NDT    :  NB TOTAL DE COMPOSANTES TENSEURS
C           NDI    :  NB DE COMPOSANTES DIRECTES  TENSEURS
C           NR     :  NB DE COMPOSANTES SYSTEME NL
C           NVI    :  NB DE VARIABLES INTERNES
C           HSR    : MATRICE D'INTERACTION POUR L'ECROUISSAGE ISOTROPE
C                    UTILISEE SEULEMENT POUR LE MONOCRISTAL IMPLICITE
C           TOUTMS : TOUS LES TENSEURS D'ORIENTATION POUR TOUS LES
C                    SYSTEMES DE GLISSEMENT
C           IMPEXP : 0 IMPLICITE, 1 EXPLICITE
C       ----------------------------------------------------------------
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
C     ----------------------------------------------------------------
      INTEGER  NMAT, NDT , NDI  , NR , NVI,NBCOMM(NMAT,3),NBVAL,NVINI
      INTEGER  KPG,KSP,IROTA, IMPEXP,NFS,NSG
      REAL*8          MATERD(NMAT,2) ,MATERF(NMAT,2)
      REAL*8          HOOK(6,6)
      REAL*8          REPERE(7),XYZ(3),KOOH(6,6),Q(3,3)
      REAL*8          EPSI,R8PREM,ANGMAS(3),PGL(3,3),R8VIDE,HOOKF(6,6)
      REAL*8          VALRES(NMAT),MS(6),NG(3), LG(3),VIND(*)
      REAL*8          HSR(NSG,NSG),TOUTMS(NFS,NSG,6)
      CHARACTER*8     MOD, NOMC(14)
      INTEGER CERR(14)
      CHARACTER*3     MATCST
      CHARACTER*(*)   FAMI
      CHARACTER*16    COMP(*),NMATER,NECOUL,NECRIS,NECRCI
      CHARACTER*16    CPMONO(5*NMAT+1),PHENOM,NOMFAM
      INTEGER I, IMAT, NBFSYS, IFA,J,DIMTMS,ITBINT
      INTEGER NBSYST,NBSYS, NBHSR
C     ----------------------------------------------------------------
C
C -   NB DE COMPOSANTES / VARIABLES INTERNES -------------------------
C
C
      CALL JEMARQ()

      IF      (MOD(1:2).EQ.'3D')THEN
         NDT = 6
         NDI = 3
      ELSE IF (MOD(1:6).EQ.'D_PLAN'.OR.MOD(1:4).EQ.'AXIS')THEN
         NDT = 6
         NDI = 3
      ELSE IF (MOD(1:6).EQ.'C_PLAN')THEN
         NDT = 6
         NDI = 3
      ENDIF
      DIMTMS=NFS*NSG*6
      CALL R8INIR(DIMTMS, 0.D0, TOUTMS, 1)
      CALL R8INIR(2*NMAT, 0.D0, MATERD, 1)
      CALL R8INIR(2*NMAT, 0.D0, MATERF, 1)

      READ (COMP(2),'(I16)') NVI

      CALL LCMMJV(COMP,NMAT,CPMONO,NBFSYS,IROTA,ITBINT,NFS,NSG,HSR)

      IF (IMPEXP.EQ.1) THEN
         IF (IROTA.NE.0) THEN
            CALL U2MESS('F','COMPOR2_11')
         ENDIF
      ENDIF

C     LA DERNIERE VARIABLE INTERNE EST L'INDICATEUR PLASTIQUE
C
      CALL MATROT(ANGMAS,PGL)

      DO 111 I=1,NMAT
      DO 111 J=1,3
         NBCOMM(I,J)=0
 111  CONTINUE
      NBCOMM(1,1)=1

      DO 6 IFA=1,NBFSYS
         NOMFAM=CPMONO(5*(IFA-1)+1)
         CALL LCMMSG(NOMFAM,NBSYS,0,PGL,MS,NG,LG,0,Q)

         NMATER=CPMONO(5*(IFA-1)+2)
         NECOUL=CPMONO(5*(IFA-1)+3)
         NECRIS=CPMONO(5*(IFA-1)+4)
         NECRCI=CPMONO(5*(IFA-1)+5)

C        COEFFICIENTS MATERIAUX LIES A L'ECOULEMENT
         CALL LCMAFL(FAMI,KPG,KSP,'-',NMATER,IMAT,NECOUL,NBVAL,VALRES,
     &            NMAT,ITBINT,NFS,NSG,HSR,NBSYS)
         NVINI=NBCOMM(IFA,1)
         IF (NECOUL.EQ.'MONO_DD_KR') THEN
            NBVAL=NBVAL+1
C           une seule matrice d'interaction pour le monocristal         
            VALRES(NBVAL)=1
         ENDIF
         DO 501 I=1,NBVAL
            MATERD(NVINI-1+I,2)=VALRES(I)
 501     CONTINUE
         NBCOMM(IFA,2)=NVINI+NBVAL

C        COEFFICIENTS MATERIAUX LIES A L'ECROUISSAGE CINEMATIQUE
         CALL LCMAEC(FAMI,KPG,KSP,'-',NMATER,IMAT,NECRCI,NBVAL,VALRES,
     &            NMAT)
         NVINI=NBCOMM(IFA,2)
         DO 502 I=1,NBVAL
            MATERD(NVINI-1+I,2)=VALRES(I)
 502     CONTINUE
         NBCOMM(IFA,3)=NVINI+NBVAL

C        COEFFICIENTS MATERIAUX LIES A L'ECROUISSAGE ISOTROPE
         CALL LCMAEI(FAMI,KPG,KSP,'-',NMATER,IMAT,NECRIS,NECOUL,NBVAL,
     &            VALRES,NMAT,ITBINT,NFS,NSG,HSR,IFA,NOMFAM,NBSYS)
         NBVAL=NBVAL+1
C        une seule matrice d'interaction pour le monocristal         
         VALRES(NBVAL)=1
         NVINI=NBCOMM(IFA,3)
         DO 503 I=1,NBVAL
            MATERD(NVINI-1+I,2)=VALRES(I)
 503     CONTINUE
         NBCOMM(IFA+1,1)=NVINI+NBVAL


 6    CONTINUE
C     ON STOCKE A LA FIN LE NOMBRE TOTAL DE COEF MATERIAU
      NBCOMM(NMAT,2)=NBFSYS
      NBCOMM(NMAT,3)=NBCOMM(NBFSYS+1,1)+1
      NBCOMM(1,1)=1

      NBSYST=0

      DO 61 IFA=1,NBFSYS

         NOMFAM=CPMONO(5*(IFA-1)+1)
         CALL LCMMSG(NOMFAM,NBSYS,0,PGL,MS,NG,LG,0,Q)
         NMATER=CPMONO(5*(IFA-1)+2)
         NECOUL=CPMONO(5*(IFA-1)+3)
         NECRIS=CPMONO(5*(IFA-1)+4)
         NECRCI=CPMONO(5*(IFA-1)+5)

         NBSYST=NBSYST+NBSYS

         CALL LCMAFL(FAMI,KPG,KSP,'+',NMATER,IMAT,NECOUL,NBVAL,
     &            VALRES,NMAT,ITBINT,NFS,NSG,HSR,NBSYS)
         NVINI=NBCOMM(IFA,1)
         IF (NECOUL.EQ.'MONO_DD_KR') THEN
            NBVAL=NBVAL+1
C           une seule matrice d'interaction pour le monocristal         
            VALRES(NBVAL)=1
         ENDIF
         DO 504 I=1,NBVAL
            MATERF(NVINI-1+I,2)=VALRES(I)
 504     CONTINUE
         NBCOMM(IFA,2)=NVINI+NBVAL

         CALL LCMAEC(FAMI,KPG,KSP,'+',NMATER,IMAT,NECRCI,NBVAL,
     &            VALRES,NMAT)
         NVINI=NBCOMM(IFA,2)
         DO 505 I=1,NBVAL
            MATERF(NVINI-1+I,2)=VALRES(I)
 505     CONTINUE
         NBCOMM(IFA,3)=NVINI+NBVAL

         CALL LCMAEI(FAMI,KPG,KSP,'+',NMATER,IMAT,NECRIS,NECOUL,NBVAL,
     &       VALRES,NMAT,ITBINT,NFS,NSG,HSR,IFA,NOMFAM,NBSYS)
         NVINI=NBCOMM(IFA,3)
         NBVAL=NBVAL+1
C        une seule matrice d'interaction pour le monocristal         
         VALRES(NBVAL)=1
         DO 506 I=1,NBVAL
            MATERF(NVINI-1+I,2)=VALRES(I)
 506     CONTINUE
         NBCOMM(IFA+1,1)=NVINI+NBVAL

 61   CONTINUE

      CALL RCCOMA(IMAT,'ELAS',PHENOM,CERR)

      IF (PHENOM.EQ.'ELAS') THEN
C
C -    ELASTICITE ISOTROPE
C
          NOMC(1) = 'E       '
          NOMC(2) = 'NU      '
          NOMC(3) = 'ALPHA   '
C
C -     RECUPERATION MATERIAU A TEMPD (T)
C
          CALL RCVALB( FAMI, KPG, KSP, '-', IMAT, ' ', 'ELAS',
     &                   0, ' ', 0.D0,
     &                   2, NOMC(1),  MATERD(1,1),  CERR(1), 1)
          CALL RCVALB( FAMI, KPG, KSP, '-', IMAT, ' ', 'ELAS',
     &                    0,  ' ', 0.D0,
     &                   1,NOMC(3),  MATERD(3,1),  CERR(3), 0)
          MATERD(NMAT,1)=0
C
C -     RECUPERATION MATERIAU A TEMPF (T+DT)
C
          CALL RCVALB( FAMI, KPG, KSP, '+',   IMAT, ' ',   'ELAS',
     &                    0, '   ', 0.D0,
     &                    2, NOMC(1),  MATERF(1,1),  CERR(1), 1)
          CALL RCVALB( FAMI, KPG, KSP, '+',   IMAT, ' ',   'ELAS',
     &                    0, '  ',0.D0,
     &                   1,NOMC(3),  MATERF(3,1),  CERR(3), 0)
          IF ( CERR(3) .NE. 0 ) MATERF(3,1) = 0.D0
          MATERF(NMAT,1)=0

      ELSE IF (PHENOM.EQ.'ELAS_ORTH') THEN

        REPERE(1)=1
        DO 21 I=1,3
           REPERE(I+1)=ANGMAS(I)
 21     CONTINUE
C
C -    ELASTICITE ORTHOTROPE
C
C
C -     MATRICE D'ELASTICITE ET SON INVERSE A TEMPD(T)
C
        CALL DMAT3D(FAMI,IMAT,R8VIDE(),'-',KPG,KSP,REPERE,XYZ,
     &              HOOK)
        CALL D1MA3D(FAMI,IMAT,R8VIDE(),'-',KPG,KSP,REPERE,XYZ,
     &              KOOH)

           DO 67 J=4,6
           DO 67 I=1,6
             HOOK(I,J) = HOOK(I,J)*SQRT(2.D0)
 67        CONTINUE
           DO 68 J=1,6
           DO 68 I=4,6
             HOOK(I,J) = HOOK(I,J)*SQRT(2.D0)
 68        CONTINUE
           DO 69 J=4,6
           DO 69 I=1,6
             KOOH(I,J) = KOOH(I,J)/SQRT(2.D0)
 69        CONTINUE
           DO 70 J=1,6
           DO 70 I=4,6
             KOOH(I,J) = KOOH(I,J)/SQRT(2.D0)
 70        CONTINUE

        DO 101 I=1,6
           DO 102 J=1,6
              MATERD(6*(J-1)+I,1)=HOOK(I,J)
              MATERD(36+6*(J-1)+I,1)=KOOH(I,J)
 102       CONTINUE
 101    CONTINUE

        MATERD(NMAT,1)=1

        NOMC(1) = 'ALPHA_L'
        NOMC(2) = 'ALPHA_T'
        NOMC(3) = 'ALPHA_N'

        CALL RCVALB(FAMI,KPG,KSP,'-',IMAT,' ',PHENOM,0,' ',0.D0,
     &              3,NOMC,MATERD(73,1),CERR,0)
        IF (CERR(1).NE.0) MATERD(73,1) = 0.D0
        IF (CERR(2).NE.0) MATERD(74,1) = 0.D0
        IF (CERR(3).NE.0) MATERD(75,1) = 0.D0


C
C -     MATRICE D'ELASTICITE ET SON INVERSE A A TEMPF (T+DT)
C
        CALL DMAT3D(FAMI,IMAT,R8VIDE(),
     &              '+',KPG,KSP,REPERE,XYZ,HOOKF)
        CALL D1MA3D(FAMI,IMAT,R8VIDE(),
     &              '+',KPG,KSP,REPERE,XYZ,KOOH)

           DO 671 J=4,6
           DO 671 I=1,6
             HOOKF(I,J) = HOOKF(I,J)*SQRT(2.D0)
 671        CONTINUE
           DO 681 J=1,6
           DO 681 I=4,6
             HOOKF(I,J) = HOOKF(I,J)*SQRT(2.D0)
 681        CONTINUE
           DO 691 J=4,6
           DO 691 I=1,6
             KOOH(I,J) = KOOH(I,J)/SQRT(2.D0)
 691        CONTINUE
           DO 701 J=1,6
           DO 701 I=4,6
             KOOH(I,J) = KOOH(I,J)/SQRT(2.D0)
 701        CONTINUE
        DO 103 I=1,6
           DO 104 J=1,6
              MATERF(6*(J-1)+I,1)=HOOKF(I,J)
              MATERF(36+6*(J-1)+I,1)=KOOH(I,J)
 104       CONTINUE
 103    CONTINUE

        MATERF(NMAT,1)=1

        CALL RCVALB(FAMI,KPG,KSP,'+',IMAT,' ',PHENOM,0,' ',0.D0,
     &              3,NOMC,MATERD(73,1),CERR,0)
        IF (CERR(1).NE.0) MATERF(73,1) = 0.D0
        IF (CERR(2).NE.0) MATERF(74,1) = 0.D0
        IF (CERR(3).NE.0) MATERF(75,1) = 0.D0

      ELSE
         CALL U2MESK('F','ALGORITH4_65',1,PHENOM)
      ENDIF

         NR=NDT+NBSYST
      CALL CALCMM(NBCOMM,CPMONO,NMAT,PGL,NFS,NSG,TOUTMS,COMP,NVI,
     &             VIND,IROTA)
C
C -   MATERIAU CONSTANT ?
C
      MATCST = 'OUI'
      EPSI=R8PREM()
      DO 30 I = 1,NMAT
        IF (ABS(MATERD(I,1)-MATERF(I,1) ).GT.EPSI*MATERD(I,1)) THEN
        MATCST = 'NON'
        GOTO 9999
        ENDIF
 30   CONTINUE
      DO 40 I = 1,NMAT
        IF (ABS(MATERD(I,2)-MATERF(I,2) ).GT.EPSI*MATERD(I,2)) THEN
        MATCST = 'NON'
        GOTO 9999
        ENDIF
 40   CONTINUE
C
 9999 CONTINUE
      CALL JEDEMA()
      END
