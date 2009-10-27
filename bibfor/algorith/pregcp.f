      SUBROUTINE PREGCP(NEQ,NBLIAI,TOLE,EPSI,MU,APCOEF,APDDL,
     &                  APPOIN,INLIAC,MATASS,SSGRAD,SSGRPR,SECMBR,
     &                  VEZERO,DELTAU,SOLVEU,PREMAX)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 27/10/2009   AUTEUR TARDIEU N.TARDIEU 
C ======================================================================
C COPYRIGHT (C) 1991 - 2006  EDF R&D                  WWW.CODE-ASTER.ORG
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

      IMPLICIT     NONE

      INTEGER NEQ,NBLIAI,APDDL(*),APPOIN(*),INLIAC(*),PREMAX
      REAL*8 APCOEF(*),SSGRAD(*),SSGRPR(*),MU(*)
      REAL*8 TOLE,EPSI
      CHARACTER*19 MATASS,SOLVEU
      CHARACTER*24 SECMBR,VEZERO,DELTAU
C ======================================================================
C ROUTINE APPELEE PAR : ALGOCG
C ======================================================================
C - PRECONDITIONNEMENT DE L'ALGORITHME DU GRADIENT CONJUGUE PROJETE
C - RESOLUTION D'UN PROBLEME ANNEXE A DEPLACEMENT IMPOSE SUR LES NOEUDS
C - EFFECTIVEMENT EN CONTACT.
C
C --------------- DEBUT DECLARATIONS NORMALISEES JEVEUX ---------------
C
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC,CBID
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------
C

      REAL*8        UU(NEQ),GRAD(NBLIAI)
      REAL*8        NUMER,DENOM,CONVER,DDOT,ALPHA
      REAL*8        ADU(NBLIAI),DIRECH(NBLIAI),NUMERP,NUMERM,BETA
      REAL*8        CONVM, COEF, RBID
      PARAMETER     (COEF=1.D-2)
      INTEGER       ILIAC,LLIAC,JDECAL,NBDDL,I,ITERAT,NBLIAC,II
      INTEGER       JDELTA,JSECMB,IFM,NIV,ISMAEM
      CHARACTER*19  KBID
C ----------------------------------------------------------------------

C ======================================================================
C                             INITIALISATIONS
C ======================================================================
      CALL JEMARQ()

      CALL INFNIV(IFM,NIV)

C --- RECUPERATION DE L'ADRESSE DU VECTEUR DE TRAVAIL
      CALL JEVEUO(DELTAU(1:19)//'.VALE','E',JDELTA)
      CALL JEVEUO(SECMBR(1:19)//'.VALE','E',JSECMB)

C --- COMPTAGE DU NOMBRE DE LIAISONS REELLEMENT ACTIVES
      NBLIAC = 0
      DO 10 ILIAC = 1,NBLIAI
        IF ((MU(ILIAC).GT.TOLE) .OR. (SSGRAD(ILIAC).GT.EPSI)) THEN
          NBLIAC = NBLIAC + 1
          INLIAC(NBLIAC) = ILIAC
        END IF
   10 CONTINUE
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<CONTACT> <> <> PRECONDITIONNEUR DIRICHLET'
        WRITE (IFM,9010) NBLIAC, EPSI
      END IF

C --- NOMBRE D'ITERATIONS MAX
      IF (PREMAX.EQ.ISMAEM()) PREMAX=2*NBLIAC

C --- SI AUCUNE LIAISON ACTIVE ON SORT CAR
C --- LE PRECONDITIONNEUR EST INUTILE
      IF (NBLIAC.EQ.0) THEN
        CALL DCOPY(NBLIAI,SSGRAD,1,SSGRPR,1)
        GO TO 120
      END IF

C --- MISE A ZERO DES VECTEURS DE TRAVAIL
      CALL R8INIR(NEQ,0.D0,UU,1)
      CALL R8INIR(NBLIAI,0.D0,GRAD,1)
      ITERAT = 1


C ======================================================================
C =========================== BOUCLE PRINCIPALE ========================
C ======================================================================
   20 CONTINUE

      CALL R8INIR(NEQ,0.D0,ZR(JDELTA),1)
      CALL R8INIR(NBLIAI,0.D0,ADU,1)

C --- NOUVELLE VALEUR DU GRADIENT
      DO 30 ILIAC = 1,NBLIAC
        LLIAC = INLIAC(ILIAC)
        JDECAL = APPOIN(LLIAC)
        NBDDL = APPOIN(LLIAC+1) - APPOIN(LLIAC)
C       GRAD=A(AC,:)*UU-SSGRAD(AC)
        CALL CALADU(NEQ,NBDDL,APCOEF(1+JDECAL),APDDL(1+JDECAL),UU,
     &              GRAD(ILIAC))
        GRAD(ILIAC) = GRAD(ILIAC) - SSGRAD(LLIAC)
   30 CONTINUE


C --- TEST DE CONVERGENCE
      CONVER = -1.D0
      DO 40 I = 1,NBLIAC
        CONVER = MAX(CONVER,ABS(GRAD(I)))
   40 CONTINUE
      IF (NIV.GE.2) THEN
        IF (ITERAT.EQ.1) CONVM=10*CONVER/COEF
        IF (CONVER.LT.(COEF*CONVM)) THEN
          WRITE (IFM,9000) ITERAT,CONVER
          CONVM=CONVER
        END IF
      END IF


C --- ON A CONVERGE
      IF (CONVER.LT.EPSI) THEN
        IF (NIV.GE.2) THEN
          WRITE (IFM,9020) ITERAT,CONVER
        END IF
        GO TO 90
      END IF

C --- NOUVELLE DIRECTION DE RECHERCHE
C --- DIRECH=GRAD+BETA*DIRECH
      IF ((ITERAT.EQ.1).OR.(MOD(ITERAT,20).EQ.0)) THEN
        NUMERP = DDOT(NBLIAI,GRAD,1,GRAD,1)
        CALL DCOPY(NBLIAI,GRAD,1,DIRECH,1)
      ELSE
        NUMERM = NUMERP
        NUMERP = DDOT(NBLIAI,GRAD,1,GRAD,1)
        BETA = NUMERP/NUMERM
        CALL DSCAL(NBLIAI,BETA,DIRECH,1)
        CALL DAXPY(NBLIAI,1.D0,GRAD,1,DIRECH,1)
      ENDIF



C --- CALCUL DU SECOND MEMBRE
C --- DU=A(AC,:)'*GRAD
      DO 50 ILIAC = 1,NBLIAC
        LLIAC = INLIAC(ILIAC)
        JDECAL = APPOIN(LLIAC)
        NBDDL = APPOIN(LLIAC+1) - APPOIN(LLIAC)
        CALL CALATM(NEQ,NBDDL,DIRECH(ILIAC),APCOEF(1+JDECAL),
     &              APDDL(1+JDECAL),ZR(JDELTA))
   50 CONTINUE


C --- RESOLUTION
C --- DU=K-1*A(AC,:)'*DIRECH
      CALL DCOPY(NEQ,ZR(JDELTA),1,ZR(JSECMB),1)
      CALL RESOUD(MATASS,KBID,SECMBR,SOLVEU, VEZERO, 'V',
     &                   DELTAU, KBID,0,RBID,CBID)
      CALL JEVEUO(DELTAU(1:19)//'.VALE','E',JDELTA)


C --- EVALUATION DU COMPLEMENT DE SCHUR SUR GRAD
C --- ADU=A(AC,:)*K-1*A(AC,:)'*DIRECH
      DO 60 ILIAC = 1,NBLIAC
        LLIAC = INLIAC(ILIAC)
        JDECAL = APPOIN(LLIAC)
        NBDDL = APPOIN(LLIAC+1) - APPOIN(LLIAC)
C       ADU=A(AC,:)*DU
        CALL CALADU(NEQ,NBDDL,APCOEF(1+JDECAL),APDDL(1+JDECAL),
     &              ZR(JDELTA),ADU(ILIAC))
   60 CONTINUE


C --- PAS D'AVANCEMENT
      NUMER = DDOT(NBLIAC,GRAD,1,GRAD,1)
      DENOM = DDOT(NBLIAC,GRAD,1,ADU,1)
      ALPHA = NUMER/DENOM

      IF (ALPHA.LT.0.D0) CALL U2MESS('F','CONTACT_7')


C --- ACTUALISATION DU SOUS GRADIENT ET DU DEPLACEMENT
      DO 70 ILIAC = 1,NBLIAC
        LLIAC = INLIAC(ILIAC)
        SSGRPR(LLIAC) = SSGRPR(LLIAC) + ALPHA*DIRECH(ILIAC)
   70 CONTINUE

      CALL DAXPY(NEQ,-ALPHA,ZR(JDELTA),1,UU,1)


C --- ON A ATTEINT LE NOMBRE D'ITERATION MAXIMAL
      IF (ITERAT.GE.PREMAX) GO TO 80


C --- ON N A PAS CONVERGE MAIS IL RESTE DES ITERATIONS A FAIRE
      ITERAT = ITERAT + 1
      GO TO 20

   80 CONTINUE

C     ON A DEPASSE LE NOMBRE D'ITERATIONS MAX
      IF (NIV.GE.2) THEN
        WRITE (IFM,9000) ITERAT,CONVER
        CALL U2MESI('I','CONTACT_3',1,PREMAX)
      END IF


   90 CONTINUE

C ======================================================================
C ============================= ON A CONVERGE ==========================
C ======================================================================

C     LES CRITERES DE CONVERGENCE SONT DECALES ENTRE L'APPELANT
C     ET CETTE ROUTINE. DU COUP, ON PEUT ENTRER ICI ET S'APERCEVOIR
C     QUE L'ON A RIEN A FAIRE. DANS CE CAS, ON RECOPIE.
      IF (ITERAT.EQ.1) THEN
        DO 100 ILIAC = 1,NBLIAC
          LLIAC = INLIAC(ILIAC)
          SSGRPR(LLIAC) = GRAD(ILIAC)
  100   CONTINUE
      END IF

C     ON REPROJETE LE SOUS-GRADIENT PRECONDITIONNE POUR
C     ASSURER LA POSITIVITE DES MULTIPLICATEURS
      CALL DSCAL(NBLIAI,-1.D0,SSGRPR,1)
      DO 110 II = 1,NBLIAI
        IF (MU(II).LT.TOLE) THEN
          SSGRPR(II) = MAX(SSGRPR(II),0.D0)
        END IF
  110 CONTINUE


  120 CONTINUE

      CALL JEDEMA()

 9000 FORMAT (' <CONTACT> <> <> PRECONDITIONNEUR : ITERATION =',I6,
     &        ' RESIDU =',1PE12.5)
 9010 FORMAT (' <CONTACT> <> <> PRECONDITIONNEUR : ',I6,
     &        ' LIAISON ACTIVES, CRITERE DE CONVERGENCE =',1PE12.5)
 9020 FORMAT (' <CONTACT> <> <> PRECONDITIONNEUR : ITERATION =',I6,
     &        ' RESIDU =',1PE12.5,' => CONVERGENCE')
      END
