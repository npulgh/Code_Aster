      SUBROUTINE MECEUC(STOP,POUX,OPTION,CARAEZ,LIGREL,NIN,LCHIN,LPAIN,
     &                  NOU,LCHOU,LPAOU,BASE)

      IMPLICIT NONE

      INCLUDE 'jeveux.h'
      INTEGER NIN,NOU
      CHARACTER*1 STOP
      CHARACTER*8 POUX,CARAEL
      CHARACTER*(*) BASE,OPTION
      CHARACTER*(*) LCHIN(*),LCHOU(*),LPAIN(*),LPAOU(*),LIGREL,CARAEZ

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
C ----------------------------------------------------------------------
C  BUT : CETTE ROUTINE EST UN INTERMEDIAIRE VERS LA ROUTINE CALCUL.F
C        POUR CERTAINES OPTIONS DONT LE RESULTAT EST COMPLEXE, ON
C        APPELLE 2 FOIS CALCUL EN AYANT SEPARE LES CHAMPS COMPLEXES"IN"
C        EN 2 : PARTIE REELLE ET PARTIE IMAGINAIRE
C
C
C     ENTREES:
C        STOP   :  /'S' : ON S'ARRETE SI AUCUN ELEMENT FINI DU LIGREL
C                         NE SAIT CALCULER L'OPTION.
C                  /'C' : ON CONTINUE SI AUCUN ELEMENT FINI DU LIGREL
C                         NE SAIT CALCULER L'OPTION. IL N'EXISTE PAS DE
C                         CHAMP "OUT" DANS CE CAS.
C        OPTIO  :  NOM D'1 OPTION
C        LIGREL :  NOM DU LIGREL SUR LEQUEL ON DOIT FAIRE LE CALCUL
C        NIN    :  NOMBRE DE CHAMPS PARAMETRES "IN"
C        NOU    :  NOMBRE DE CHAMPS PARAMETRES "OUT"
C        LCHIN  :  LISTE DES NOMS DES CHAMPS "IN"
C        LCHOU  :  LISTE DES NOMS DES CHAMPS "OUT"
C        LPAIN  :  LISTE DES NOMS DES PARAMETRES "IN"
C        LPAOU  :  LISTE DES NOMS DES PARAMETRES "OUT"
C        BASE   :  'G' , 'V' OU 'L'

C     SORTIES:
C       ALLOCATION ET CALCUL DES OBJETS CORRESPONDANT AUX CHAMPS "OUT"
C     CETTE ROUTINE MET EN FORME LES CHAMPS EVENTUELLEMENT COMPLEXE
C     POUR L APPEL A CALCUL
C-----------------------------------------------------------------------
C TOLE CRS_1404


      CHARACTER*19 CHDECR(NIN),CHDECI(NIN),CH19,CHR,CHI,CH1,CH2
      CHARACTER*19 LCHINR(NIN),LCHINI(NIN)
      CHARACTER*16 OPTIO2
      CHARACTER*14 VALK(1)
      CHARACTER*8 NOMGD
      INTEGER IBID,I,K,IEXI,IEXI1,IEXI2
      INTEGER INDDEC(NIN)
      LOGICAL LCMPLX,LSSPT,LDBG,LOPDEC
C ----------------------------------------------------------------------
C
      CALL JEMARQ()

      OPTIO2=OPTION
      CARAEL=CARAEZ
      CH1='&&MECEUC.CH1'
      CH2='&&MECEUC.CH2'
      LDBG=.TRUE.


C     -- 0. LA ROUTINE N'EST UTILE QUE POUR CERTAINES OPTIONS :
C     ---------------------------------------------------------
      LOPDEC=.FALSE.
      IF (OPTION.EQ.'ECIN_ELEM') LOPDEC=.TRUE.
      IF (OPTION.EQ.'EFGE_ELGA') LOPDEC=.TRUE.
      IF (OPTION.EQ.'EFGE_ELNO') LOPDEC=.TRUE.
      IF (OPTION.EQ.'ENEL_ELGA') LOPDEC=.TRUE.
      IF (OPTION.EQ.'ENEL_ELNO') LOPDEC=.TRUE.
      IF (OPTION.EQ.'EPOT_ELEM') LOPDEC=.TRUE.
      IF (OPTION.EQ.'EPSI_ELGA') LOPDEC=.TRUE.
      IF (OPTION.EQ.'EPSI_ELNO') LOPDEC=.TRUE.
      IF (OPTION.EQ.'SIEF_ELGA') LOPDEC=.TRUE.
      IF (OPTION.EQ.'SIEF_ELNO') LOPDEC=.TRUE.
      IF (OPTION.EQ.'SIGM_ELGA') LOPDEC=.TRUE.
      IF (OPTION.EQ.'SIGM_ELNO') LOPDEC=.TRUE.
      IF (OPTION.EQ.'SIPM_ELNO') LOPDEC=.TRUE.
      IF (OPTION.EQ.'SIPO_ELNO') LOPDEC=.TRUE.
      IF (OPTION.EQ.'SIPO_ELNO_SENS') LOPDEC=.TRUE.
      IF (OPTION.EQ.'EFGE_ELNO_SENS') LOPDEC=.TRUE.
      IF (.NOT.LOPDEC) THEN
         CALL CALCUL(STOP,OPTIO2,LIGREL,NIN,LCHIN,LPAIN,NOU,LCHOU,
     &               LPAOU,BASE,'OUI')
         GOTO 9999
      ENDIF


C     -- 1. Y-A-T-IL DES CHAMPS "IN" COMPLEXES ?
C           SI OUI, IL FAUT LES DECOUPER
C     -----------------------------------------------------------
      LCMPLX=.FALSE.
      DO 1, K=1,NIN
         INDDEC(K)=0
         IF (LPAIN(K).EQ.' ') GOTO 1
         CH19=LCHIN(K)
         IF (CH19.EQ.' ') GOTO 1
         IF (LDBG) CALL CHLICI(CH19,19)
         CALL EXISD('CHAMP',CH19,IEXI)
         IF (IEXI.EQ.0) GOTO 1
         CALL DISMOI('F','NOM_GD',CH19,'CHAMP',IBID,NOMGD,IBID)
C        -- MECHPO CREE PARFOIS UN CHAMP DE FORC_C
C           IL M'EMBETE ! COMMENT SAVOIR S'IL EST PERTINENT ?
         IF (NOMGD.EQ.'FORC_C') GOTO 1

         IF (NOMGD(5:6).EQ.'_C') THEN
           LCMPLX=.TRUE.
           INDDEC(K)=1
           CHR='&&MECEUC.CHXX.R'
           CHI='&&MECEUC.CHXX.I'
           CALL CODENT(K,'D0',CHR(12:13))
           CALL CODENT(K,'D0',CHI(12:13))
           CALL SEPACH(CARAEL,CH19,'V',CHR,CHI)
           CHDECR(K)=CHR
           CHDECI(K)=CHI
         ENDIF
 1    CONTINUE


C     -- 2. S'IL N'Y A AUCUN CHAMP COMPLEXE, C'EST FACILE :
C     -------------------------------------------------------
      IF (.NOT.LCMPLX) THEN
         CALL CALCUL(STOP,OPTIO2,LIGREL,NIN,LCHIN,LPAIN,NOU,LCHOU,
     &               LPAOU,BASE,'OUI')
         GOTO 9999
      ENDIF


C     -- 3. LE CHAMP "OUT" EST-IL A SOUS-POINTS ?
C     -------------------------------------------
      CALL ASSERT(NOU.EQ.1)
      CALL EXISD('CHAM_ELEM_S',LCHOU(1),IEXI)
      LSSPT=(IEXI.NE.0)


C     -- 4.0 ON PREPARE LCHINR ET LCHINI :
C     ------------------------------------
      DO 2,K=1,NIN
        IF (INDDEC(K).EQ.0) THEN
          LCHINR(K)=LCHIN(K)
          LCHINI(K)=LCHIN(K)
        ELSE
          LCHINR(K)=CHDECR(K)
          LCHINI(K)=CHDECI(K)
        ENDIF
  2   CONTINUE


C     -- 4.1 APPEL A CALCUL AVEC LES PARTIES REELLES :
C     ------------------------------------------------
      IF (LSSPT) CALL COPISD('CHAM_ELEM_S','V',LCHOU(1),CH1)
      CALL CALCUL(STOP,OPTIO2,LIGREL,NIN,LCHINR,LPAIN,NOU,CH1,
     &                  LPAOU,'V','OUI')


C     -- 4.2 APPEL A CALCUL AVEC LES PARTIES IMAGINAIRES :
C     ----------------------------------------------------
      IF (LSSPT) CALL COPISD('CHAM_ELEM_S','V',LCHOU(1),CH2)
      CALL CALCUL(STOP,OPTIO2,LIGREL,NIN,LCHINI,LPAIN,NOU,CH2,
     &                  LPAOU,'V','OUI')


C     -- 4.3 SI STOP='C' ET QUE CH1 ET CH2 N'EXISTENT PAS :
C     -----------------------------------------------------
      IF (STOP.EQ.'C') THEN
        CALL EXISD('CHAM_ELEM',CH1,IEXI1)
        CALL EXISD('CHAM_ELEM',CH2,IEXI2)
        IF (IEXI1.EQ.0) THEN
          CALL ASSERT(IEXI2.EQ.0)
          GOTO 9998
        ENDIF
      ENDIF


C     -- 6.  ASSEMBLAGE (R,I) OU CUMUL (R+I) :
C     -----------------------------------------
      IF ((OPTIO2.EQ.'SIEF_ELNO').OR.
     &    (OPTIO2.EQ.'SIGM_ELGA').OR.
     &    (OPTIO2.EQ.'SIGM_ELNO').OR.
     &    (OPTIO2.EQ.'EFGE_ELGA').OR.
     &    (OPTIO2.EQ.'EFGE_ELNO').OR.
     &    (OPTIO2.EQ.'EFGE_ELNO_SENS').OR.
     &    (OPTIO2.EQ.'SIPM_ELNO').OR.
     &    (OPTIO2.EQ.'SIPO_ELNO').OR.
     &    (OPTIO2.EQ.'SIPO_ELNO_SENS').OR.
     &    (OPTIO2.EQ.'EPSI_ELNO').OR.
     &    (OPTIO2.EQ.'EPSI_ELGA').OR.
     &    (OPTIO2.EQ.'STRX_ELGA').OR.
     &    (OPTIO2.EQ.'SIEF_ELGA')) THEN
         CALL ASSACH(CH1,CH2,BASE,LCHOU(1))

      ELSEIF ((OPTIO2.EQ.'EPOT_ELEM') .OR.
     &        (OPTIO2.EQ.'ENEL_ELGA') .OR.
     &        (OPTIO2.EQ.'ENEL_ELNO') .OR.
     &        (OPTIO2.EQ.'ECIN_ELEM')) THEN
         CALL BARYCH(CH1,CH2,1.D0,1.D0,LCHOU(1),'G')
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF



C     -- 7. MENAGE :
C     --------------
9998  CONTINUE
      DO 3,K=1,NIN
        IF (INDDEC(K).NE.0) THEN
          CALL DETRSD('CHAMP',CHDECR(K))
          CALL DETRSD('CHAMP',CHDECI(K))
        ENDIF
  3   CONTINUE

      CALL DETRSD('CHAMP',CH1)
      CALL DETRSD('CHAMP',CH2)
      CALL DETRSD('CHAM_ELEM_S',CH1)
      CALL DETRSD('CHAM_ELEM_S',CH2)


9999  CONTINUE
      CALL JEDEMA()
      END
