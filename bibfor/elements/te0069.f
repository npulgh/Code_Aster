      SUBROUTINE TE0069 ( OPTION , NOMTE )
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C ----------------------------------------------------------------------
C CALCUL DU FLUX AUX NOEUDS/POINTS DE GAUSS
C ELEMENTS ISO 2D  OPTION : 'FLUX_ELGA/ELNO' (CALCUL STD)
C                           'FLUX_ELGA/ELNO_SENS' (CALCUL SENSIBILITE)
C
C     ENTREES  ---> OPTION : OPTION DE CALCUL
C              ---> NOMTE  : NOM DU TYPE ELEMENT
C   -------------------------------------------------------------------
C     ASTER INFORMATIONS:
C       30/04/02 (OB): CALCUL DE LA SENSIBILITE DU FLUX THERMIQUE VIA
C                      L'OPTION 'FLUX_ELGA/ELNO_SENS' + MODIFS
C                      FORMELLES (IMPLICIT NONE, IDENTATION...)
C----------------------------------------------------------------------
C CORPS DU PROGRAMME
      IMPLICIT NONE

C PARAMETRES D'APPELS
      INCLUDE 'jeveux.h'
      CHARACTER*16      OPTION,NOMTE


      INTEGER ICODRE(2)
      CHARACTER*8   NOMRES(2),ELREFE,ELREF2,FAMI,POUM
      CHARACTER*16  PHENOM,PHESEN,VALK(2)
      REAL*8        DFDX(9),DFDY(9),TPG,POIDS,LAMBDA,FPG(18),LAMBOR(2),
     &              P(2,2),POINT(2),ORIG(2),FLUGLO(2),FLULOC(2),
     &              VALRES(2),LAMBS,PREC,R8PREM,LAMBOS(2),FLUGLS(2),
     &              FLULOS(2),R8DGRD,ALPHA,FLUXX,FLUXY,FLUSX,FLUSY,
     &              XU,YU,XNORM,TRACE
      INTEGER       NNO,KP,K,ITEMPE,ITEMP,IFLUX,J,NNOS,IFPG,NDIM,
     &              IPOIDS,IVF,IDFDE,IGEOM,IMATE,NPG,JGANO,
     &              IMATSE,ITEMSE,NUNO,ICAMAS,NCMP,KPG,SPT
      LOGICAL       ANISO,GLOBAL,LSENS

C====
C 1.1 PREALABLES: RECUPERATION ADRESSES FONCTIONS DE FORMES...
C====
      PREC = R8PREM()
      CALL ELREF1(ELREFE)
      ELREF2 = ELREFE
      FAMI='FPG1'
      KPG=1
      SPT=1
      POUM='+'
C
C
      IF ( OPTION(1:9).EQ. 'FLUX_ELNO') THEN
          CALL ELREF4(ELREF2,'GANO',NDIM,NNO,NNOS,NPG,IPOIDS,IVF,
     &                IDFDE,JGANO)

      ELSE  IF ( OPTION(1:9).EQ. 'FLUX_ELGA') THEN
          CALL ELREF4(ELREF2,'RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,IVF,
     &                IDFDE,JGANO)
      ENDIF

C====
C 1.2 PREALABLES LIES AUX CALCULS DE SENSIBILITE
C====
C CALCUL DE SENSIBILITE PART I
      IF (OPTION(11:14).EQ.'SENS') THEN
        LSENS = .TRUE.
        CALL JEVECH('PMATSEN','L',IMATSE)
        CALL JEVECH('PTEMSEN','L',ITEMSE)
      ELSE
        LSENS = .FALSE.
      ENDIF

C====
C 1.3 PREALABLES LIES AUX RECHERCHES DE DONNEES GENERALES
C====
      CALL JEVECH('PGEOMER','L',IGEOM )
      CALL JEVECH('PMATERC','L',IMATE )
      CALL JEVECH('PTEMPSR','L',ITEMP )
      CALL JEVECH('PTEMPER','L',ITEMPE)
      CALL JEVECH('PFLUX_R','E',IFLUX )
      CALL RCCOMA(ZI(IMATE),'THER',PHENOM,ICODRE)
C CALCUL DE SENSIBILITE PART II. TEST DE COHERENCE PHENOM STD/
C PHENOM MAT DERIVEE
      IF (LSENS) THEN
        CALL RCCOMA(ZI(IMATSE),'THER',PHESEN,ICODRE)
        IF (PHESEN.NE.PHENOM) THEN
          VALK(1)=PHESEN
          VALK(2)=PHENOM
          CALL U2MESK('F','ELEMENTS_38',2,VALK)
        ENDIF
      ENDIF

C====
C 1.4 PREALABLES LIES A LA RECUPERATION DES DONNEES MATERIAUX EN
C     THERMIQUE LINEAIRE ISOTROPE OU ORTHOTROPE
C====
      LAMBDA = 0.D0
      IF ( PHENOM .EQ. 'THER') THEN
         NOMRES(1) = 'LAMBDA'
         CALL RCVALB(FAMI,KPG,SPT,POUM,ZI(IMATE),' ',PHENOM,1,'INST',
     &               ZR(ITEMP),1,NOMRES,VALRES,ICODRE,1)
         LAMBDA = VALRES(1)
         ANISO = .FALSE.

C CALCUL DE SENSIBILITE PART III (ISOTROPE)
        IF (LSENS) THEN
          CALL RCVALB(FAMI,KPG,SPT,POUM,ZI(IMATSE),' ',PHENOM,1,'INST',
     &                ZR(ITEMP),1,NOMRES,LAMBS,ICODRE,1)
C SI SENSIBILITE /RHO_CP OU /AUTRE LAMBDA ON A PAS DE TERME COMPLE
C MENTAIRE A ASSEMBLER
          IF (ABS(LAMBS).LT.PREC) LSENS = .FALSE.
        ENDIF

      ELSEIF ( PHENOM .EQ. 'THER_ORTH') THEN
         NOMRES(1) = 'LAMBDA_L'
         NOMRES(2) = 'LAMBDA_T'
         CALL RCVALB(FAMI,KPG,SPT,POUM,ZI(IMATE),' ',PHENOM,1,'INST',
     &               ZR(ITEMP),2,NOMRES,VALRES,ICODRE,1)
         LAMBOR(1) = VALRES(1)
         LAMBOR(2) = VALRES(2)
         ANISO = .TRUE.

C CALCUL DE SENSIBILITE PART IV (ORTHOTROPE)
        IF (LSENS) THEN
          CALL RCVALB(FAMI,KPG,SPT,POUM,ZI(IMATSE),' ',PHENOM,1,'INST',
     &                ZR(ITEMP),2,NOMRES,VALRES,ICODRE,1)
C SI SENSIBILITE /RHO_CP OU /AUTRE LAMBDA ON A PAS DE TERME COMPLE
C MENTAIRE A ASSEMBLER
          LAMBOS(1) = VALRES(1)
          LAMBOS(2) = VALRES(2)
          TRACE = LAMBOS(1) + LAMBOS(2)
          IF (ABS(TRACE).LT.PREC) LSENS = .FALSE.
        ENDIF

      ELSEIF ( PHENOM .EQ. 'THER_NL') THEN
        ANISO = .FALSE.

C CALCUL DE SENSIBILITE PART V (THERMIQUE NON-LINEAIRE)
        IF (LSENS) THEN
          TPG = 0.D0
          CALL RCVALB(FAMI,KPG,SPT,POUM,ZI(IMATSE),' ',PHENOM,1,
     &              'TEMP',TPG,1,'LAMBDA',LAMBS,ICODRE,1)
          IF (ABS(LAMBS).LT.PREC) LSENS = .FALSE.
        ENDIF

      ELSE
        CALL U2MESS('F','ELEMENTS2_63')
      ENDIF

C====
C 1.5 PREALABLES LIES A L'ANISOTROPIE
C====
      ORIG(1) = 0.D0
      ORIG(2) = 0.D0
      GLOBAL  = .FALSE.
      IF ( ANISO ) THEN
        CALL JEVECH('PCAMASS','L',ICAMAS)
        IF (ZR(ICAMAS).GT.0.D0) THEN
          GLOBAL = .TRUE.
          ALPHA  = ZR(ICAMAS+1)*R8DGRD()
          P(1,1) =  COS(ALPHA)
          P(2,1) =  SIN(ALPHA)
          P(1,2) = -SIN(ALPHA)
          P(2,2) =  COS(ALPHA)
        ELSE
          ORIG(1) = ZR(ICAMAS+4)
          ORIG(2) = ZR(ICAMAS+5)
        ENDIF
      ENDIF

C====
C 2. CALCULS TERMES DE FLUX (STD ET/OU SENSIBLE)
C====
      DO 101 KP=1,NPG
        K=(KP-1)*NNO
        IFPG=(KP-1)*2
        CALL DFDM2D ( NNO,KP,IPOIDS,IDFDE,ZR(IGEOM),DFDX,DFDY,POIDS )
        TPG   = 0.0D0
        FLUXX = 0.0D0
        FLUXY = 0.0D0
        IF ( .NOT.GLOBAL .AND. ANISO ) THEN
          POINT(1)=0.D0
          POINT(2)=0.D0
          DO 103 NUNO=1,NNO
            POINT(1) = POINT(1) + ZR(IVF+K+NUNO-1)*ZR(IGEOM+2*NUNO-2)
            POINT(2) = POINT(2) + ZR(IVF+K+NUNO-1)*ZR(IGEOM+2*NUNO-1)
 103      CONTINUE
          XU = ORIG(1) - POINT(1)
          YU = ORIG(2) - POINT(2)
          XNORM = SQRT( XU**2 + YU**2 )
          XU = XU / XNORM
          YU = YU / XNORM
          P(1,1) =  XU
          P(2,1) =  YU
          P(1,2) = -YU
          P(2,2) =  XU
        ENDIF

C     CALCUL DE T ET DE GRAD(T) AUX POINTS DE GAUSS (EN STD)
C     OU DE DT/DS ET GRAD(DT/DS) (EN SENSIBILITE)
        DO 110 J=1,NNO
          TPG   = TPG   + ZR(ITEMPE+J-1)*ZR(IVF+K+J-1)
          FLUXX = FLUXX + ZR(ITEMPE+J-1)*DFDX(J)
          FLUXY = FLUXY + ZR(ITEMPE+J-1)*DFDY(J)
 110    CONTINUE

C CALCUL DE SENSIBILITE PART VI : CALCUL DE T ET DE GRAD(T)
        IF (LSENS) THEN
          TPG   = 0.0D0
          FLUSX = 0.0D0
          FLUSY = 0.0D0
          DO 108 J=1,NNO
            TPG  = TPG  +  ZR(ITEMSE-1+J) * ZR(IVF+K+J-1)
            FLUSX = FLUSX +  ZR(ITEMSE-1+J) * DFDX(J)
            FLUSY = FLUSY +  ZR(ITEMSE-1+J) * DFDY(J)
108       CONTINUE
        ENDIF
        IF (PHENOM.EQ.'THER_NL') THEN
           CALL RCVALB(FAMI,KPG,SPT,POUM,ZI(IMATE),' ',PHENOM,1,
     &                  'TEMP',TPG,1,'LAMBDA',LAMBDA,ICODRE,1)
        ENDIF
        IF (.NOT.ANISO) THEN
          FLUGLO(1) = LAMBDA*FLUXX
          FLUGLO(2) = LAMBDA*FLUXY
C CALCUL DE SENSIBILITE PART VII: RAJOUT TERME COMPLEMENTAIRE (ISO)
          IF (LSENS) THEN
            FLUGLO(1) = FLUGLO(1) + LAMBS*FLUSX
            FLUGLO(2) = FLUGLO(2) + LAMBS*FLUSY
          ENDIF
        ELSE
          FLULOC(1) = P(1,1)*FLUXX + P(2,1)*FLUXY
          FLULOC(2) = P(1,2)*FLUXX + P(2,2)*FLUXY
          FLULOC(1) = LAMBOR(1)*FLULOC(1)
          FLULOC(2) = LAMBOR(2)*FLULOC(2)
          FLUGLO(1) = P(1,1)*FLULOC(1) + P(1,2)*FLULOC(2)
          FLUGLO(2) = P(2,1)*FLULOC(1) + P(2,2)*FLULOC(2)
C CALCUL DE SENSIBILITE PART VIII: RAJOUT TERME COMPLEMENTAIRE (ORT)
          IF (LSENS) THEN
            FLULOS(1) = P(1,1)*FLUSX + P(2,1)*FLUSY
            FLULOS(2) = P(1,2)*FLUSX + P(2,2)*FLUSY
            FLULOS(1) = LAMBOS(1)*FLULOS(1)
            FLULOS(2) = LAMBOS(2)*FLULOS(2)
            FLUGLS(1) = P(1,1)*FLULOS(1) + P(1,2)*FLULOS(2)
            FLUGLS(2) = P(2,1)*FLULOS(1) + P(2,2)*FLULOS(2)
            FLUGLO(1) = FLUGLO(1) + FLUGLS(1)
            FLUGLO(2) = FLUGLO(2) + FLUGLS(2)
          ENDIF
        ENDIF

        FPG(IFPG+1) = -FLUGLO(1)
        FPG(IFPG+2) = -FLUGLO(2)

 101  CONTINUE
C

      IF ( OPTION(1:9).EQ. 'FLUX_ELNO' ) THEN

C ----- RECUPERATION DE LA MATRICE DE PASSAGE PTS DE GAUSS - NOEUDS
        NCMP = 2
        CALL PPGAN2 ( JGANO, 1, NCMP, FPG, ZR(IFLUX) )
      ELSE
        DO 90 KP=1,NPG
          ZR(IFLUX+(KP-1)*2)   = FPG(2*(KP-1)+1)
          ZR(IFLUX+(KP-1)*2+1) = FPG(2*(KP-1)+2)
 90     CONTINUE
      ENDIF

      END
