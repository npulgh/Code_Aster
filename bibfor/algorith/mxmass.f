      SUBROUTINE MXMASS(MODELE,NUMEDD,MATE,  CARELE,COMREF, 
     &                  COMPOR,LISCHA,MEDIRI,METHOD,SOLVEU, 
     &                  CARCRI,ITERAT,VALMOI,POUGD, DEPDEZ,
     &                  VALPLU,MATRIX,OPTION,STADYN,PREMIE, 
     &                  DEPENT,VITENT,MEMASS,MASSE, AMORT , 
     &                  LICCVG,SDDYNA)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 04/04/2007   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2003  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE BOYERE E.BOYERE
C TOLE CRP_21
C
      IMPLICIT NONE
      INTEGER       ITERAT, LICCVG
      CHARACTER*(*) DEPDEZ
      CHARACTER*16  METHOD(*),OPTION
      CHARACTER*19  LISCHA,SOLVEU,MATRIX(2),SDDYNA
      CHARACTER*24  MODELE,NUMEDD,MATE,CARELE,COMREF,COMPOR
      CHARACTER*24  CARCRI,VALMOI,POUGD,VALPLU
      CHARACTER*24  MEDIRI,STADYN
      CHARACTER*24  DEPENT,VITENT,MEMASS,MEAMOR,AMORT
      LOGICAL       PREMIE
C 
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGORITHME - EXPLICITE)
C
C CALCUL DE LA MATRICE DE MASSE
C      
C ----------------------------------------------------------------------
C 
C
C IN  MODELE : MODELE
C IN  NUMEDD : NUME_DDL
C IN  MATE   : CHAMP MATERIAU
C IN  CARELE : CARACTERISTIQUES DES ELEMENTS DE STRUCTURE
C IN  COMREF : VARI_COM DE REFERENCE
C IN  COMPOR : COMPORTEMENT
C IN  LISCHA : L_CHARGES
C IN  MEDIRI : MATRICES ELEMENTAIRES DE DIRICHLET (B)
C IN  METHOD : INFORMATIONS SUR LES METHODES DE RESOLUTION
C IN  SOLVEU : SOLVEUR
C IN  CARCRI : PARAMETRES DES METHODES D'INTEGRATION LOCALES
C IN  ITERAT : NUMERO D'ITERATION
C IN  VALMOI : ETAT EN T-
C IN  POUGD  : DONNES POUR POUTRES GRANDES DEFORMATIONS
C IN  DEPDEZ : INCREMENT DE DEPLACEMENT
C IN  VALPLU : ETAT EN T+
C OUT MATRIX : MATRICE ASSEMBLEE
C                 (1) : MATASS 
C                 (2) : MAPREC - PRECONDITIONNEMENT
C OUT OPTION : NOM D'OPTION PASSE A MERIMO ('CORRECTION')
C OUT LICCVG : CODE RETOUR (INDIQUE SI LA MATRICE EST SINGULIERE)
C                O -> MATRICE INVERSIBLE
C                1 -> MATRICE SINGULIERE
C                2 -> MATRICE PRESQUE SINGULIERE
C                3 -> ON NE SAIT PAS SI LA MATRICE EST SINGULIERE
C
C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
C
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------
C
      REAL*8       COEVIT,COEACC
      LOGICAL      TABRET(0:10),NDYNLO
      INTEGER      JCFSC,JINFC,IACHAR,IACHA2
      REAL*8       INSTAM,UN,COEF2(3)
      CHARACTER*8  NOMDDL
      CHARACTER*19 MATASS,MAPREC
      CHARACTER*24 MERIGI,VERESI,VEDIRI,DEPDEL
      CHARACTER*24 MASSE,LIMAT(3)
      CHARACTER*4  TYPMAT,TYPCST(3)
      INTEGER      I,NBCHAR,NBMAT
C
      DATA VERESI,VEDIRI/'&&RESIDU.LISTE_RESU','&&DIRICH.LISTE_RESU'/
      DATA MERIGI /'&&MEMRIG.LISTE_RESU'/
      DATA MEAMOR /'&&NMMATR.AMORT'/
      DATA NOMDDL /'        '/
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      MATASS    = '&&MATMAS'
      MAPREC    = '&&NMMATR.MAPREC'
      DEPDEL    = DEPDEZ
      LICCVG    = 0
      UN        = 1.D0
      COEF2(1)  = UN
      CALL JEVEUO(SDDYNA(1:15)//'.COEF_SCH','L',JCFSC)
      COEVIT    = ZR(JCFSC+2-1)
      COEACC    = ZR(JCFSC+3-1)
      COEF2(2)  = COEACC
      COEF2(3)  = COEVIT
      TYPCST(1) = 'R'
      TYPCST(2) = 'R'
      TYPCST(3) = 'R'
      TYPMAT    = 'R'
      CALL NMIMPR('IMPR','MATR_ASSE','YTR',0.D0,0)

C -- CALCUL DE LA MATRICE DE RIGIDITE

C -- CALCUL DES MATRICES ELEMENTAIRES D AMORTISSEMENT
      IF (NDYNLO(SDDYNA,'MAT_AMORT')) THEN
C ======================================================================
C               CALCUL DES MATRICES TANGENTES ELEMENTAIRES
C ======================================================================
         IF (PREMIE.OR.METHOD(5).EQ.'TANGENTE') THEN
           OPTION = 'RIGI_MECA_TANG'
           CALL MERIMO(MODELE,CARELE,MATE,COMREF,COMPOR,LISCHA,CARCRI,
     &                 DEPDEL,POUGD,STADYN,DEPENT,VITENT,VALMOI,VALPLU,
     &                 OPTION,MERIGI,VERESI,VEDIRI,ITERAT+1,TABRET)
         END IF
         CALL JEVEUO(LISCHA//'.INFC','L',JINFC)
         NBCHAR = ZI(JINFC)
         CALL JEVEUO(LISCHA//'.LCHA','L',IACHAR)
         CALL WKVECT('&&MXMASS.LISTE_CHARGE','V V K8',NBCHAR,IACHA2)
         DO 20,I = 1,NBCHAR
            ZK8(IACHA2-1+I) = ZK24(IACHAR-1+I) (1:8)
   20    CONTINUE
         CALL MEAMME('AMOR_MECA',MODELE,NBCHAR,ZK8(IACHA2),MATE,
     &               CARELE,.TRUE.,INSTAM,MERIGI,MEMASS,MEAMOR)
         CALL JEDETR('&&MXMASS.LISTE_CHARGE')
         CALL ASMAAM(MEAMOR,NUMEDD,SOLVEU,LISCHA,AMORT)
         CALL MTDSCR(AMORT)
      END IF

C -- AU PREMIER PASSAGE, INITIALISATION DES MATRICES MATASS
C -- ET MASSE
      IF (PREMIE) THEN
         PREMIE = .FALSE.
         CALL ASMAMA(MEMASS,MEDIRI,NUMEDD,SOLVEU,LISCHA,
     &               MASSE)
         CALL MTDSCR(MASSE)
         LIMAT(1) = MASSE

C -- CALCUL DE LA MATRICE MATASS
         NBMAT = 1
         CALL DETRSD('MATR_ASSE',MATASS)
         CALL MTDEFS(MATASS,MASSE,'V',TYPMAT)
         CALL MTCMBL(NBMAT,TYPCST,COEF2,LIMAT,MATASS,NOMDDL,' ')
C      FACTORISATION
         CALL PRERES(SOLVEU,'V',LICCVG,MAPREC,MATASS)
         CALL MTDSCR(MATASS)
         MATRIX(1) = MATASS
         MATRIX(2) = MAPREC
      ELSE
         MATRIX(1) = '&&MATMAS'
         MATRIX(2) = '&&NMMATR.MAPREC'
      END IF

9999  CONTINUE

      CALL JEDEMA()
      END
