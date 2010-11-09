      SUBROUTINE HUJRES (MOD, CRIT, MATER, IMAT, NVI, EPSD, DEPS,
     &           SIGD, VIND, SIGF, VINF, IRET, ETATF)
      IMPLICIT NONE
C          CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 08/11/2010   AUTEUR REZETTE C.REZETTE 
C ======================================================================
C COPYRIGHT (C) 1991 - 2007  EDF R&D                  WWW.CODE-ASTER.ORG
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
C   ------------------------------------------------------------------
C   INTEGRATION PLASTIQUE DE LA LOI DE HUJEUX
C   IN  MOD    :  MODELISATION
C       CRIT   :  CRITERES DE CONVERGENCE
C       MATER  :  COEFFICIENTS MATERIAU A T+DT
C       NVI    :  NOMBRE DE VARIABLES INTERNES
C       EPSD   :  DEFORMATIONS A T
C       DEPS   :  INCREMENT DE DEFORMATION
C       SIGD   :  CONTRAINTE  A T
C       VIND   :  VARIABLES INTERNES  A T
C   VAR SIGF   :  CONTRAINTE A T+DT  (IN -> ELAS, OUT -> PLASTI)
C   OUT VINF   :  VARIABLES INTERNES A T+DT
C                 (CUMUL DECOUPAGE)
C       NDEC   :  NOMBRE DE DECOUPAGE
C       IRET   :  CODE RETOUR DE  L'INTEGRATION DE LA LOI DE HUJEUX
C                    IRET=0 => PAS DE PROBLEME
C                    IRET=1 => ECHEC 
C       ETATF  :  ETAT PLASTIQUE OU ELASTIQUE DU POINT DE GAUSS
C   ------------------------------------------------------------------
      INTEGER       NDT, NDI, NVI, NDEC, IRET
      INTEGER       I, K, IFM, NIV, JJ, NSUBD, MAJ
      INTEGER       NVIMAX, IDEC, IMAT, INDI(7)
      PARAMETER     (NVIMAX=50)
      REAL*8        EPSD(6), DEPS(6),VINS(NVIMAX)
      REAL*8        SIGD(6), SIGF(6), PREDIC(6), PTRAC
      REAL*8        SIGD0(6), DEPS0(6), PREDI0(6)
      REAL*8        VIND(*), VINF(*), VIND0(NVIMAX)
      REAL*8        MATER(22,2), CRIT(*), CRITR(8)
      REAL*8        PF, QF, VEC(3), ZERO, PREF
      REAL*8        VINT(NVIMAX), DEUX, R8PREM
      REAL*8        TOL, ASIG, ADSIG, TOLE1, RTRAC
      LOGICAL       CHGMEC, NOCONV, AREDEC, STOPNC, NEGMUL(8)
      LOGICAL       SUBD, RDCTPS, LOOP, IMPOSE
      CHARACTER*8   MOD
      CHARACTER*7   ETATF
      LOGICAL       DEBUG, PLAS, TRY, NODEC, TRACT

      COMMON /TDIM/   NDT, NDI
      COMMON /MESHUJ/ DEBUG

      DATA ZERO, DEUX   / 0.D0, 2.D0/
      DATA TOL, TOLE1 / .5D0, 1.D-7 /

      IF (NVI.GT.NVIMAX) CALL U2MESS('F', 'COMPOR1_1')

      TRY = .TRUE.
      LOOP = .FALSE.
      NODEC=.FALSE.

      DO 70 I = 1, 7
        INDI(I) = 0
  70    CONTINUE

      PTRAC  = MATER(21,2)
      PREF   = MATER(8,2)
      RTRAC  = ABS(1.D-6*PREF)

      CALL INFNIV(IFM,NIV)
      
C ----  SAUVEGARDE DES GRANDEURS D ENTREE INITIALES
      CALL LCEQVE(SIGF,PREDI0)
      CALL LCEQVE(SIGD,SIGD0)
      CALL LCEQVE(DEPS,DEPS0)
      CALL LCEQVN(NVI,VIND,VIND0)
      
C  ARRET OU NON EN NON CONVERGENCE INTERNE
C  ---------------------------------------
      IF (INT(CRIT(1)).LT.0) THEN
        STOPNC = .TRUE.
      ELSE
        STOPNC = .FALSE.
      ENDIF


C  INITIALISATION DES VARIABLES DE REDECOUPAGE
C  -------------------------------------------
C  INT( CRIT(5) ) = 0  1 OU -1 ==> PAS DE REDECOUPAGE DU PAS DE TEMPS
      IF ((INT(CRIT(5)) .EQ.  0) .OR.
     &    (INT(CRIT(5)) .EQ. -1) .OR.
     &    (INT(CRIT(5)) .EQ.  1)) THEN
        NDEC   = 1
        NODEC  = .TRUE.
        AREDEC = .TRUE.
        NOCONV = .FALSE.


C ---- INT( CRIT(5) ) < -1 ==> REDECOUPAGE DU PAS DE TEMPS
C                            SI NON CONVERGENCE
      ELSEIF (INT(CRIT(5)) .LT. -1) THEN
        NDEC   = 1
        AREDEC = .FALSE.
        NOCONV = .FALSE.


C ---- INT( CRIT(5) ) > 1 ==> REDECOUPAGE IMPOSE DU PAS DE TEMPS
      ELSEIF (INT(CRIT(5)) .GT. 1) THEN
        NDEC   = INT(CRIT(5))
        AREDEC = .TRUE.
        NOCONV = .FALSE.
      ENDIF


C  POINT DE RETOUR EN CAS DE DECOUPAGE POUR DR/R > TOLE OU 
C  APRES UNE NON CONVERGENCE, POUR  INT(CRIT(5)) < -1

      SUBD = .FALSE.
      RDCTPS = .FALSE.

  500 CONTINUE
      IF (NOCONV) THEN
        NDEC   = 3
        IRET   = 0
        AREDEC = .TRUE.
        NOCONV = .FALSE.
      ENDIF

      IF (SUBD) THEN
        NDEC = NSUBD
        IRET = 0
        AREDEC = .TRUE.         
        TRY    = .FALSE.
      ENDIF
      
      IF (RDCTPS) THEN
        NDEC = 3
        IRET = 0
        AREDEC = .TRUE.         
      ENDIF

C   RESTAURATION DE SIGD VIND DEPS ET PREDIC ELAS SIGF
C   EN TENANT COMPTE DU DECOUPAGE EVENTUEL
      CALL LCEQVE (SIGD0, SIGD)
      CALL LCEQVN (NVI, VIND0, VIND)
      
      DO  10 I = 1, NDT
       DEPS(I) = DEPS0(I)/NDEC
 10    CONTINUE

C      CALL HUJELA(MOD,CRIT,MATER,DEPS,SIGD,SIGF,EPSD,IRET)
      CALL HUJPRE('ELASTIC', MOD, CRIT, IMAT, MATER, DEPS,
     &            SIGD, SIGF, EPSD, VIND, IRET)

CKH ON IMPOSE UNE CONDITION SUR LA VARIATION DE DSIGMA
C   < 50% de SIGMA_INIT
      ASIG = 0.D0
      ADSIG= 0.D0
      
      DO 12 I = 1, NDT
        ASIG = ASIG + SIGD(I)**2.D0
        ADSIG= ADSIG+ (SIGF(I)-SIGD(I))**2.D0
 12   CONTINUE
      ASIG = SQRT(ASIG)
      ADSIG= SQRT(ADSIG)
      
      IF ((-ASIG/PREF) .GT. TOLE1) THEN
        NSUBD = NINT(ADSIG/ASIG/TOL)
        IF (NSUBD.GT.1) THEN
          NDEC  = MIN(NDEC*NSUBD,100)
          DO 11 I = 1, NDT
            DEPS(I) = DEPS0(I)/NDEC
 11         CONTINUE
        ENDIF
      ENDIF

      IF (DEBUG) THEN

        WRITE(IFM,*)
        WRITE(IFM,'(A)') '================== HUJRES =================='
        WRITE(IFM,*)
        WRITE(IFM,1001) 'NDEC=',NDEC

      ENDIF

C               INIT BOUCLE SUR LES DECOUPAGES
C  =============================================================
      DO 400 IDEC = 1, NDEC

C --- MISE A JOUR DU COMPTEUR D'ITERATIONS LOCALES
        LOOP     = .FALSE.
        VIND(35) = VIND0(35) + IDEC
       
        IF (DEBUG) THEN

          WRITE(IFM,*)
          WRITE(IFM,1001) '%% IDEC=',IDEC

        ENDIF

        MAJ = 0
        CALL LCEQVE(SIGF,PREDIC)
      
        DO 20 K = 1, 8
          NEGMUL(K)=.FALSE.
 20       CONTINUE

C ---> SAUVEGARDE DES SURFACES DE CHARGE AVANT MODIFICATION
        CALL LCEQVN(NVI,VIND,VINS)
C ---> DEFINITION DU DOMAINE POTENTIEL DE MECANISMES ACTIFS

        CALL HUJPOT(MOD,MATER,VIND,DEPS,SIGD,SIGF,ETATF,
     &           RDCTPS,IRET,AREDEC) 
        IF (IRET.EQ.1) GOTO 9999
      
        IF (RDCTPS .AND. (.NOT. AREDEC)) THEN
          GOTO 500
        ELSEIF (RDCTPS .AND. (AREDEC)) THEN
          IRET = 1        
          GOTO 9999
        ENDIF  


C ---> SI ELASTICITE PASSAGE A L'ITERATION SUIVANTE        
        PLAS = .FALSE.
        IF (ETATF .EQ. 'ELASTIC') THEN
          DO 29 I = 1, 3
            CALL HUJPRJ(I, SIGF, VEC, PF, QF)
            IF (((PF+DEUX*RTRAC-PTRAC)/ABS(PREF)).GE.ZERO) THEN
              PLAS  = .TRUE.
              ETATF = 'PLASTIC'
            ENDIF
  29        CONTINUE
  
          IF (.NOT.PLAS) THEN
            DO 30 I=1,NVI
              VINF(I)=VIND(I)  
 30           CONTINUE
            CHGMEC = .FALSE.        
            GOTO 40       
          ENDIF
        ENDIF
      
      
C ---> SINON RESOLUTION VIA L'ALGORITHME DE NEWTON
        CHGMEC = .FALSE.

        CALL LCEQVN (NVI, VIND, VINF)
      IF (DEBUG) WRITE(6,*)'HUJRES - VINF =',(VINF(I),I=24,31)

 100    CONTINUE
C--->   RESOLUTION EN FONCTION DES MECANISMES ACTIVES
C       MECANISMES ISOTROPE ET DEVIATOIRE
C-----------------------------------------------------

        CALL HUJMID (MOD, CRIT, MATER, NVI, EPSD, DEPS,
     &    SIGD, SIGF, VIND, VINF, NOCONV, AREDEC, STOPNC,
     &    NEGMUL, IRET, SUBD, LOOP, NSUBD, INDI, TRACT)

C --- ON CONTROLE QUE LES PRESSIONS ISOTROPES PAR PLAN
C     NE PRESENTENT PAS DE TRACTION
        DO 48 I = 1, NDI
          CALL HUJPRJ(I, SIGF, VEC, PF, QF)
          IF (((PF+RTRAC-PTRAC)/ABS(PREF)).GT.ZERO) THEN
            NOCONV=.TRUE.
            IF (DEBUG) WRITE(6,'(A)')'HUJRES :: SOL EN TRACTION'
          ENDIF
 48     CONTINUE
C --- SI TRACTION DETECTEE ET NON CONVERGENCE, ON IMPOSE
C --- ETAT DE CONTRAINTES ISOTROPE
        IF((NOCONV).AND.(TRACT))THEN
          NOCONV=.FALSE.
          DO 51 I = 1, 3
            SIGF(I)     = -DEUX*RTRAC
            SIGF(3+I)   = ZERO
            VIND(23+I)  = ZERO
            VIND(27+I)  = ZERO
            VIND(5+4*I) = ZERO
            VIND(6+4*I) = ZERO
            VIND(7+4*I) = ZERO
            VIND(8+4*I) = ZERO
 51       CONTINUE
          CALL LCEQVN(NVI,VIND,VINF)
          IRET = 0
          IF (DEBUG) WRITE(6,'(A)')'HUJRES :: CORRECTION SIGMA'
        ENDIF
C --- SI PROCHE TRACTION ET NON CONVERGENCE, ON IMPOSE
C --- ETAT DE CONTRAINTES ISOTROPE
        IF(NOCONV)THEN 
          IMPOSE = .FALSE.
          DO 49 I = 1, NDI
            CALL HUJPRJ(I, SIGF, VEC, PF, QF)
            IF ((ABS(PF-PTRAC)/ABS(PREF)).LT.1D-5) THEN
              IMPOSE = .TRUE.
              IF (DEBUG) WRITE(6,'(A)')'HUJRES :: SOL LIQUEFIE'
            ENDIF
 49       CONTINUE
          IF(IMPOSE)THEN
            NOCONV = .FALSE.
            DO 47 I = 1, 3
              SIGF(I)     = -DEUX*RTRAC
              SIGF(3+I)   = ZERO
              VIND(23+I)  = ZERO
              VIND(27+I)  = ZERO
              VIND(5+4*I) = ZERO
              VIND(6+4*I) = ZERO
              VIND(7+4*I) = ZERO
              VIND(8+4*I) = ZERO
 47         CONTINUE
            CALL LCEQVN(NVI,VIND,VINF)
            IRET = 0
            ENDIF
        ENDIF

C --- PRISE DE DECISION POUR LA SUITE DE L'ALGORITHME
C --- ECHEC DE L'INTEGRATION
        IF (IRET.EQ.1) GOTO 9999

C --- REDECOUPAGE LOCAL SI POSSIBLE
        IF ((NOCONV .OR. SUBD) .AND. (.NOT. AREDEC)) GOTO 500

C --- REDECOUPAGE LOCAL SI ENCORE POSSIBLE
        IF (SUBD .AND. TRY. AND. NODEC) GOTO 500

C --- NON CONVERGENCE D'OU ECHEC D'INTEGRATION LOCAL
        IF (NOCONV) THEN
          IF (DEBUG) WRITE(6,'(A)')'HUJRES :: PROBLEME AVEC NOCONV ' 
          IRET = 1
          GOTO 9999
        ENDIF         

C --- REPRISE A CE NIVEAU SI MECANISME SUPPOSE ELASTIQUE   
  40    CONTINUE        
          
C --- VERIFICATION DES MECANISMES SUPPOSES ACTIFS
C                 DES MULTIPLICATEURS PLASTIQUES
C                 DES SEUILS EN DECHARGE

        CALL HUJACT(MATER, VIND, VINF, VINS, SIGD, SIGF,
     &              NEGMUL, CHGMEC, INDI, IRET)
        IF (IRET.EQ.1) GOTO 9999
  
C - SI ON MODIFIE LE DOMAINE POTENTIEL DE MECANISMES ACTIVES : RETOUR
C   AVEC UNE CONDITION DE CONVERGENCE DE LA METHODE DE NEWTON
        IF (CHGMEC) THEN
          IF (.NOT. AREDEC) THEN
C --- REDECOUPAGE ACTIVE S'IL NE L'ETAIT PAS ENCORE
            CHGMEC = .FALSE.
            NOCONV = .TRUE.
            GOTO 500
          ELSE
C --- REPRISE DE L'ITERATION EN TENANT COMPTE DES MODIFICATIONS
            IF (DEBUG) WRITE(IFM,'(A)')
     &              'HUJRES :: CHANGEMENT DE MECANISME'
            CHGMEC = .FALSE.

C --- REINITIALISATION DE SIGF A LA PREDICTION ELASTIQUE PREDIC
C            CALL LCEQVE (PREDIC, SIGF)
C --- PREDICTEUR MIS A JOUR TENANT COMPTE DE L'ETAT PRECEDEMMENT OBTENU
            MAJ = MAJ + 1
            IF (MAJ.LT.5) THEN
              LOOP = .TRUE.
              CALL LCEQVN (NVI, VIND, VINF)
              GOTO 100
            ELSE      
              IF (DEBUG) WRITE(6,'(A)') 'HUJRES :: SOLUTION EXPLICITE'
            ENDIF            
          ENDIF
        ENDIF        
C End - CHGMEC
C --- S'IL N'Y A PAS DE CHANGEMENT DE MECANISME, ON POURSUIT
        
        MAJ = 0
        IF (IDEC .LT. NDEC) THEN
          CALL LCEQVE (SIGF, SIGD)
          DO 50 I = 1, NVI
            VIND(I) = VINF(I)
 50         CONTINUE
          DO 60 I = 1, NDT
            DEPS(I) = DEPS0(I)/NDEC
 60       CONTINUE
C --- APPLICATION DE L'INCREMENT DE DÉFORMATIONS, SUPPOSE ELASTIQUE  
C          CALL HUJELA(MOD,CRIT,MATER,DEPS,SIGD,SIGF,EPSD,IRET)
          CALL HUJPRE('ELASTIC', MOD, CRIT, IMAT, MATER, DEPS,
     &            SIGD, SIGF, EPSD, VIND, IRET)         
        ENDIF
        
 400    CONTINUE
C End - Boucle sur les redecoupages


9999  CONTINUE

2000  FORMAT(A,10(1X,E12.5))
1001  FORMAT(A,I3)
      IF(DEBUG)WRITE(6,*)'IRET - HUJRES =',IRET
      END
