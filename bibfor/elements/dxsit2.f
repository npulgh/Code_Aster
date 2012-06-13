      SUBROUTINE DXSIT2(NOMTE,PGL,SIGMA)
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      CHARACTER*16 NOMTE
      REAL*8 PGL(3,3),SIGMA(*)
C ----------------------------------------------------------------------
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.         
C ======================================================================
C
C     BUT:
C       CALCUL LES CONTRAINTES VRAIES AUX POINTS DE GAUSS
C       RETRANCHE LES CONTRAINTES PLANES D'ORIGINE THERMIQUE AUX POINTS
C       DE GAUSS, POUR LES ELEMENTS COQUES A FACETTES PLANES :
C       DST, DKT, DSQ, DKQ, Q4G DUS :
C       .A UN CHAMP DE TEMPERATURES MOYEN ET
C       .A UN GRADIENT DE TEMPERATURES DANS L'EPAISSEUR DE LA COQUE
C       DANS LE CAS ELASTIQUE ISOTROPE HOMOGENE
C       CAS ELAS_COQMU
C
C     ARGUMENTS:
C     ----------
C
C      ENTREE :
C-------------
C IN   NOMTE    : NOM DU TYPE D'ELEMENT
C IN   PGL(3,3) : MATRICE DE PASSAGE DU REPERE GLOBAL AU REPERE LOCAL
C IN   SIGMA(*) : CONTRAINTES PLANES MECANIQUES AUX POINTS DE GAUSS
C
C      SORTIE :
C-------------
C OUT  SIGMA(*) : CONTRAINTES PLANES VRAIES AUX POINTS DE GAUSS
C
C ......................................................................
C
C
C
C
      INTEGER NDIM,NNO,NNOS,NPG,IPOIDS,ICOOPG,IVF,IDFDX,IDFD2,JGANO
      INTEGER IRET1,IRET2,IRET3,IRET4,IRET5
      INTEGER ICOU,ICOU2,NBCOU,IPG,IGAUH,NPGH,ICPG,NBCMP,IMOY
      INTEGER JNBSPI,JMATE
      INTEGER INDITH,ICODRE

      REAL*8 DM(3,3),TREF
      REAL*8 TINF(4),TMOY(4),TSUP(4)
      REAL*8 ORDI,EPI,EPAIS,COE1,COE2

      CHARACTER*4 FAMI
      CHARACTER*10 PHENOM

      LOGICAL DKG
C
C ----------------------------------------------------------------------
C
C --- INITIALISATIONS :
C     -----------------
      FAMI = 'RIGI'
      CALL ELREF5(' ',FAMI,NDIM,NNO,NNOS,NPG,IPOIDS,ICOOPG,
     &                                         IVF,IDFDX,IDFD2,JGANO)
C
      IRET1 = 0
      IRET2 = 0
      IRET3 = 0
      IRET4 = 0
      IRET5 = 0
C
      DKG    = .FALSE.
C
      IF ((NOMTE.EQ.'MEDKTG3').OR.
     &    (NOMTE.EQ.'MEDKQG4')) THEN
        DKG = .TRUE.
      END IF
C
C --- RECUPERATION DU NOMBRE DE COUCHE ET DE SOUS-POINT
C     -------------------------------------------------
      IF (DKG) THEN
        NBCOU = 1
        NPGH = 1
        NBCMP = 6
      ELSE
        CALL JEVECH('PNBSP_I','L',JNBSPI)
        NPGH = 3
        NBCOU = ZI(JNBSPI-1+1)
        NBCMP = 6
        IF (NBCOU.LE.0) CALL U2MESS('F','ELEMENTS_46')
      ENDIF
      IMOY=(3*NBCOU+1)/2
C
C --- RECUPERATION DE LA TEMPERATURE DE REFERENCE
C     -------------------------------------------------
      CALL RCVARC(' ','TEMP','REF','RIGI',1,1,TREF,IRET1)
C     S'IL N'Y A PAS DE TEMPERATURE DE REFERENCE, ON NE FAIT RIEN
      IF(IRET1.EQ.1) GOTO 9999
C
C --- RECUPERATION DE LA TEMPERATURE SUR LES FEUILLETS
C     ------------------------------------------------
      DO 5 IPG=1,NPG
        CALL RCVARC(' ','TEMP','+','RIGI',IPG,1,TINF(IPG),IRET2)
        CALL RCVARC(' ','TEMP','+','RIGI',IPG,IMOY,TMOY(IPG),IRET3)
        CALL RCVARC(' ','TEMP','+','RIGI',IPG,3*NBCOU,TSUP(IPG),IRET4)
        IRET5 = IRET5+IRET2+IRET3+IRET4
5     CONTINUE

      CALL JEVECH('PMATERC','L',JMATE)
      CALL RCCOMA(ZI(JMATE),'ELAS',PHENOM,ICODRE)

C --- CAS NON TRAITES PAR CETTE ROUTINE
      IF ((PHENOM.EQ.'ELAS')       .OR.
     &    (PHENOM.EQ.'ELAS_ISTR')  .OR.
     &    (PHENOM.EQ.'ELAS_ORTH')  .OR.
     &    (PHENOM.EQ.'ELAS_COQUE') ) THEN
        CALL U2MESK('A','ELEMENTS_52',1,PHENOM(1:10))
        GOTO 9999
      ENDIF

C --- CALCUL DES MATRICES DE HOOKE DE FLEXION, MEMBRANE,
C --- MEMBRANE-FLEXION, CISAILLEMENT, CISAILLEMENT INVERSE
C     ----------------------------------------------------
C
C --- BOUCLE SUR LES POINTS DE GAUSS
C     ------------------------------
      DO 100 IPG=1,NPG
        DO 110 ICOU=1,NBCOU
          DO 120 IGAUH=1,NPGH
            ICPG=NBCMP*NPGH*NBCOU*(IPG-1)+
     &            NBCMP*NPGH*(ICOU-1)+
     &             NBCMP*(IGAUH-1)
C
            ICOU2 = ICOU
            CALL DXMAT2(PGL,ICOU2,NPG,ORDI,EPI,EPAIS,DM,INDITH)
            INDITH=0
            IF (INDITH.EQ.-1) GOTO 9999

            IF (IRET5.EQ.0) THEN
              IF (IRET1.EQ.1) THEN
                CALL U2MESS('F','CALCULEL_15')
              ELSE
C
C  --      LES COEFFICIENTS SUIVANTS RESULTENT DE L'HYPOTHESE SELON
C  --      LAQUELLE LA TEMPERATURE EST PARABOLIQUE DANS L'EPAISSEUR.
C  --      LES COEFFICIENTS THERMOELASTIQUES PROVIENNENT DES
C  --      MATRICES QUI SONT LES RESULTATS DE LA ROUTINE DXMATL.
C          ----------------------------------------
                COE1 = (TSUP(IPG)+TINF(IPG)+4.D0*TMOY(IPG))/6.D0 - TREF
                COE2 = (TSUP(IPG)-TINF(IPG))*
     &                  (ORDI+DBLE(IGAUH-2)*EPI/2.D0)/EPAIS
C
                SIGMA(1+ICPG) = SIGMA(1+ICPG) -
     &                               ((DM(1,1)+DM(1,2))/EPI)*(COE1+COE2)
                SIGMA(2+ICPG) = SIGMA(2+ICPG) -
     &                               ((DM(2,1)+DM(2,2))/EPI)*(COE1+COE2)
                SIGMA(4+ICPG) = SIGMA(4+ICPG) -
     &                               ((DM(3,1)+DM(3,2))/EPI)*(COE1+COE2)
C
              ENDIF
            ENDIF
C
 120      CONTINUE
 110    CONTINUE
 100  CONTINUE
C
9999  CONTINUE

      END
