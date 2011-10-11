        SUBROUTINE LCMMLC(NMAT,NBCOMM,CPMONO,NFS,NSG,HSR,NSFV,NSFA,IFA,
     &      NBSYS,IS,DT,NVI,VIND,YD,DY,ITMAX,TOLER,MATERF,EXPBP,TAUS,
     &                  DALPHA,DGAMMA,DP,CRIT,SGNS,RP,IRET)
        IMPLICIT NONE
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 10/10/2011   AUTEUR PROIX J-M.PROIX 
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
C TOLE CRP_21
C       ----------------------------------------------------------------
C     MONOCRISTAL  : CALCUL DE L'ECOULEMENT VISCOPLASTIQUE
C     IN  NMAT   :  DIMENSION MATER
C         NBCOMM :  INCIDES DES COEF MATERIAU
C         CPMONO :  NOM DES COMPORTEMENTS
C         HSR    :  MATRICE D'INTERACTION
C         NVI    :  NOMBRE DE VARIABLES INTERNES
C         NSFV   :  DEBUT DES SYST. GLIS. DE LA FAMILLE IFA DANS VIND
C         NSFA   :  DEBUT DES SYST. GLIS. DE LA FAMILLE IFA DANS Y
C         NBSYS  :  NOMBRE DE SYSTEMES DE LA FAMILLE IFA
C         IS     :  NUMERO DU SYST. GLIS. ACTUEL
C         DT     :  ACCROISSEMENT DE TEMPS
C         NVI    :  NOMBRE DE VARIABLES INTERNES AU TOTAL
C         VIND   :  VARIABLES INTERNES A L'INSTANT PRECEDENT
C         YD     :  VARIABLES A T       
C         DY     :  SOLUTION ESSAI      
C         ITMAX  :  ITER_INTE_MAXI
C         TOLER  :  RESI_INTE_RELA
C         MATERF :  COEFFICIENTS MATERIAU A T+DT
C         EXPBP  :  EXPONENTIELLES POUR LE COMPORTEMENT VISC1
C         TAUS   :  SCISSION REDUITE SYSTEME IS

C  OUT    DALPHA :  DALPHA ENTRE T ET T+DT ITERATION COURANTE
C         DGAMMA :  DGAMMA ENTRE T ET T+DT ITERATION COURANTE
C         DP     :  NORME DE L'ACCROISSEMENT GLIS.PLAS.
C         CRIT   :  CRITERE ATTEINT POUR TAUS (SUIVANT LA LOI)
C         SGNS   :  SIGNE DE TAUS (-C.ALPHA POUR VISC1)
C         RP     :  ECROUISSAGE
C         IRET   :  CODE RETOUR
C     ----------------------------------------------------------------
      INTEGER NMAT, NVI, NSFV, IRET, IFL, NFS, NSG
      INTEGER NUVI,IFA,NBSYS,IS,ITMAX,IEXP
      INTEGER NBCOMM(NMAT,3),NSFA,NUECOU
      REAL*8 DT,VIND(NVI)
      REAL*8 MATERF(NMAT*2),DY(*),YD(*),TOLER
      REAL*8 TAUS,DGAMMA,DALPHA,DP,RP
      REAL*8 HSR(NSG,NSG)
      REAL*8 DGAMM1,ALPHAM
      REAL*8 CRIT,ALPHAP,SGNS,GAMMAP,EXPBP(NSG)
      CHARACTER*16 CPMONO(5*NMAT+1)
      CHARACTER*16 NECOUL,NECRIS,NECRCI
C     ----------------------------------------------------------------
C
      IFL=NBCOMM(IFA,1)           
      NUECOU=NINT(MATERF(NMAT+IFL))
      NECOUL=CPMONO(5*(IFA-1)+3)
      NECRIS=CPMONO(5*(IFA-1)+4)
      NECRCI=CPMONO(5*(IFA-1)+5)

      
      NUVI=NSFV+3*(IS-1)

C     ECROUISSAGE CINEMATIQUE - CALCUL DE DALPHA-SAUF MODELES DD
      IF ((NUECOU.LT.4).OR.(NUECOU.GT.6)) THEN

          DGAMM1=DY(NSFA+IS)
          ALPHAM=VIND(NUVI+1)
          CALL LCMMFC( MATERF(NMAT+1),IFA,NMAT,NBCOMM,NECRCI,
     &      ITMAX, TOLER,ALPHAM,DGAMM1,DALPHA, IRET)

          ALPHAP=ALPHAM+DALPHA
          GAMMAP=YD(NSFA+IS)+DGAMM1
      ELSE
C        POUR DD_*,  ALPHA est la variable principale
         ALPHAP=YD(NSFA+IS)+DY(NSFA+IS)
      ENDIF
      
      IF (NUECOU.NE.4) THEN
C        ECROUISSAGE ISOTROPE : CALCUL DE R(P)
         IEXP=0
         IF (IS.EQ.1) IEXP=1
         CALL LCMMFI(MATERF(NMAT+1),IFA,NMAT,NBCOMM,NECRIS,IS,
     &               NBSYS,VIND(NSFV+1),DY(NSFA+1),NFS,NSG,HSR,IEXP,
     &               EXPBP,RP)
      ENDIF
      
C     ECOULEMENT VISCOPLASTIQUE
C     ROUTINE COMMUNE A L'IMPLICITE (PLASTI-LCPLNL)
C     ET L'EXPLICITE (NMVPRK-GERPAS-RK21CO-RDIF01)
C     CAS IMPLICITE : IL FAUT PRENDRE EN COMPTE DT
C     CAS EXPLICITE : IL NE LE FAUT PAS (C'EST FAIT PAR RDIF01)
C
      CALL LCMMFE( TAUS,MATERF(NMAT+1),MATERF(1),IFA,NMAT,NBCOMM,
     &             NECOUL,IS,NBSYS,VIND(NSFV+1),DY(NSFA+1),
     & RP,ALPHAP,GAMMAP,DT,DALPHA,DGAMMA,DP,CRIT,SGNS,NFS,NSG,HSR,IRET)
     
      END
