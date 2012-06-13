      SUBROUTINE CRELIL(KSTOP,NBMAT,ILIMAT,LILI,BASE,NOMMA,PREF,GD,
     &                  MAILLA,NEC,NCMP,ILIMO,NLILI,
     &                  NBELM)

      IMPLICIT REAL*8 (A-H,O-Z)
C
      INCLUDE 'jeveux.h'
      INTEGER NBMAT,ILIMAT,GD,NEC,ILIMO,NLILI,ICONX1,ICONX2,NBELM,
     &        IADNEM,IADLIE
      CHARACTER*(*) LILI,NOMMA,PREF,MAILLA
      CHARACTER*1 BASE,KSTOP
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ASSEMBLA  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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

C
C ---- OBJET : CREATION DU CHAMP .LILI A PARTIR D'UNE LISTE DE MATR_ELEM
C
C ---- DESCRIPTION DES PARAMETRES
C IN  K1   KSTOP  : (VOIR L'ARGUMENT "OUT" NLILI)
C IN  I    NBMAT  : NBRE DE MATR_ELEM
C IN  I    ILIMAT : ADRESSE DE LA LISTE DES MAT_ELE
C IN  K*24 LILI   : NOM DE L OBJET LILI QUI SERA CREE
C IN  K1   BASE   : ' G ' POUR CREER LILI SUR BASE GLOBALE
C                   ' V ' POUR CREER LILI SUR BASE VOLATILE
C IN  K*24 NOMMA  : NOM FORFAITAIRE DU LIGREL &MAILLA
C IN  K*19 PREF   : PREFIXE DES OBJETS TEMPORAIRES CREES
C
C OUT I    GD     : GRANDEUR SIMPLE ASSOCIEE AU NUME_DDL
C OUT K*8  MAILLA : NOM DU MAILLAGE
C OUT I    NEC    : NBRE D ENTIERS CODES POUR GD
C OUT I    NCMP   : NBRE DE CMP POUR GD
C OUT I    ILIMO  : NUMERO DANS LE REPERTOIRE LILI DU NOM DU 1ER LIGREL
C                   APPARTENANT A UNE S.D. DE TYPE MODELE , =0 SINON
C OUT I    NLILI  : DIMENSION DE L OBJET CREE K24LIL
C                   SI NLILI=1, C'EST QU'ON N'A TROUVE AUCUN RESUELEM
C                   => ERREUR FATALE SI KSTOP='F'
C                   => ON CONTINUE   SI KSTOP='C'
C OUT I    NBELM  : NBRE D ELEMENTS DU MAILLAGE
C    --- DESCRIPTION DES OBJETS ADNE ET ADLI ---
C     ADNE (1          ) = NBRE DE MAILLES DU MAILLAGE
C     ADNE (2          ) = 0
C     ADNE (3          ) = 0
C     ADLI (1          ) = NBRE DE MAILLES DU MAILLAGE
C     ADLI (2          ) = 0
C     ADLI (3          ) = 0
C     POUR 2<=ILI<=NLILI
C     ADNE (3*(ILI-1)+1) = NBRE MAX D'OBJETS DE LA COLLECTION
C                            LILI(ILI).NEMA
C     ADNE (3*(ILI-1)+2) = ADRESSE DE L'OBJET LILI(ILI).NEMA
C     ADNE (3*(ILI-1)+3) = ADRESSE DU VECTEUR DES LONG. CUMULEES DE
C                            LILI(ILI).NEMA
C     ADLI (3*(ILI-1)+1) = NBRE MAX D'OBJETS DE LA COLLECTION
C                            LILI(ILI).LIEL
C     ADLI (3*(ILI-1)+2) = ADRESSE DE L'OBJET LILI(ILI).LIEL
C     ADLI (3*(ILI-1)+3) = ADRESSE DU VECTEUR DES LONG. CUMULEES DE
C                            LILI(ILI).LIEL
C-----------------------------------------------------------------------
C     FONCTIONS JEVEUX
C-----------------------------------------------------------------------
C-----------------------------------------------------------------------
C-----------------------------------------------------------------------
      CHARACTER*8 MODELE,MODELS,EXISS1,EXISS2
      CHARACTER*16 SUROPT,SUROPS,PHENO
C----------------------------------------------------------------------
C     VARIABLES LOCALES
C----------------------------------------------------------------------
      CHARACTER*8 KBID
      CHARACTER*19 PREFIX,MATEL
      CHARACTER*24 RESU,NOMLI,K24LIL,KMAILL
C-----------------------------------------------------------------------
C     FONCTIONS LOCALES D'ACCES AUX DIFFERENTS CHAMPS DES
C     S.D. MANIPULEES DANS LE SOUS PROGRAMME
C-----------------------------------------------------------------------
      CHARACTER*1 K1BID
C----------------------------------------------------------------------
C                DEBUT DES INSTRUCTIONS
C----------------------------------------------------------------------
      K24LIL = LILI
      KMAILL = NOMMA
      PREFIX = PREF
C
C---- CALCUL DU NBRE DE LIGRELS REFERENCES
C
      IDIMLI = 1
      SUROPS= ' '
      MODELS= ' '
      EXISS2= 'NON'
C
C     -- VERIFICATION DES MATR_ELEM :
C     -------------------------------
      DO 100 IMAT = 1,NBMAT
         MATEL = ZK24(ILIMAT+IMAT-1)(1:19)
         CALL JEEXIN(MATEL//'.RERR',IRET1)
         CALL ASSERT(IRET1.GT.0)
         CALL JEVEUO(MATEL//'.RERR','L',IAREFR)
         MODELE= ZK24(IAREFR-1+1)(1:8)
         SUROPT= ZK24(IAREFR-1+2)(1:16)
         IF (((MODELE.NE.MODELS).AND.(MODELS.NE.' '))
     &    .OR.((SUROPT(5:9).NE.SUROPS(5:9)).AND.(SUROPS.NE.' '))) THEN
C        LE TEST SUIVANT PLANTE LA THERMIQUE OU ON ASSEMBLE
C        LA RIGIDITE AVEC LA MASSE !!
C    +    .OR.((SUROPT.NE.SUROPS).AND.(SUROPS.NE.' '))) THEN
             CALL U2MESS('F','ASSEMBLA_18')
         END IF
         MODELS= MODELE
         SUROPS= SUROPT
C
         CALL DISMOI('F','NB_SS_ACTI',MATEL,'MATR_ELEM',N1,KBID,IERD)
         IF(N1.GT.0) THEN
           EXISS1= 'OUI'
           EXISS2= 'OUI'
         ELSE
           EXISS1= 'NON'
         END IF
C
         CALL JEEXIN(MATEL//'.RELR',IRET)
         IF (IRET.GT.0) THEN
           CALL JELIRA(MATEL//'.RELR','LONUTI',NBRESU,K1BID)
           IF(NBRESU.GT.0)CALL JEVEUO(MATEL//'.RELR','L',IDLRES)
           IDIMLI = IDIMLI + NBRESU
         ELSE
           IF (EXISS1(1:3).EQ.'NON') CALL U2MESS('F','ASSEMBLA_19')
         END IF
  100 CONTINUE
C
C     --SI IL EXISTE DES SOUS-STRUCTURES, ON COMPTE 1 LIGREL DE PLUS:
C
      IF (EXISS2(1:3).EQ.'OUI') IDIMLI=IDIMLI+1
C
      CALL DISMOI('F','NOM_MAILLA',MODELE,'MODELE',IBID,MAILLA(1:8),
     &             IERD)
      CALL DISMOI('F','PHENOMENE',MODELE,'MODELE',IBID,PHENO,IERD)
      CALL DISMOI('F','NUM_GD',PHENO,'PHENOMENE',GD,KBID,IERD)
C
C---- CALCUL DE NEC ET NCMP
C
      NEC = NBEC(GD)
      NCMP = NBCMP(GD)
C
C
C
C---- CREATION DU REPERTOIRE .LILI DE TOUS LES NOMS DE LIGRELS /=
C     TROUVES DANS LES RESUELEMS ATTEINT A PARTIR DE LA LISTE DES
C     MATR_ELEM + EN 1ER LE MOT '&MAILLA'
C
      CALL JEEXIN(K24LIL,IRET)
      IF (IRET.GT.0) CALL JEDETR(K24LIL)
      CALL JECREO(K24LIL,BASE//' N  K24 ')
      CALL JEECRA(K24LIL,'NOMMAX',IDIMLI,' ')
C---- LILI(1)= '&MAILLA'
      CALL JECROC(JEXNOM(K24LIL,KMAILL))
C---- SI LES RESUELEM SONT VIDES .LILI NE CONTIENT QUE &MAILLA
      NLILI = 1
      IF (IDIMLI.EQ.1) GOTO 101
C
C---- CALCUL DE LILI
C
      DO 110 IMAT = 1,NBMAT
         MATEL = ZK24(ILIMAT+IMAT-1)(1:19)
         CALL JEEXIN(MATEL//'.RELR',IRET)
         IF (IRET.EQ.0) GO TO 110
         CALL JELIRA(MATEL//'.RELR','LONUTI ',NBRESU,K1BID)
         IF(NBRESU.GT.0)CALL JEVEUO(MATEL//'.RELR','L',IDLRES)
         DO 120 IRESU = 1,NBRESU
            RESU = ZK24(IDLRES+IRESU-1)
C
            CALL JEEXIN(RESU(1:19)//'.NOLI',IRET)
            IF (IRET.EQ.0) GOTO 120
            CALL JEVEUO(RESU(1:19)//'.NOLI','L',IAD)
            NOMLI = ZK24(IAD)
            CALL JENONU(JEXNOM(K24LIL,NOMLI),ILI)
            IF (ILI.EQ.0) THEN
C
C           ---- SI CE LIGREL N EST PAS DANS LILI ON LE MET
C
               CALL JEEXIN(NOMLI(1:19)//'.NBNO',IRET)
               IF (IRET.NE.0) THEN
                  CALL JEVEUO(NOMLI(1:19)//'.NBNO','L',IAD)
               ELSE
               END IF
               NLILI = NLILI + 1
               CALL JECROC(JEXNOM(K24LIL,NOMLI))
            END IF
  120    CONTINUE
  110 CONTINUE
C
C     -- ON REGARDE SI ON DOIT AJOUTER LE LIGREL DE MODELE POUR LES
C     -- SOUS-STRUCTURES:
      IF (EXISS2(1:3).EQ.'OUI') THEN
         ICOMP=0
         DO 777  ILI = 1,NLILI
            CALL JENUNO(JEXNUM(K24LIL,ILI),NOMLI)
            IF (NOMLI(1:8).EQ.MODELE) ICOMP =1
 777     CONTINUE
         IF (ICOMP.EQ.0) THEN
            NLILI= NLILI+1
            CALL JECROC(JEXNOM(K24LIL,MODELE//'.MODELE'))
         END IF
      END IF
C


      IF (NLILI.EQ.1) THEN
        IF (KSTOP.EQ.'C') THEN
          GOTO 9999
        ELSE
          CALL ASSERT(KSTOP.EQ.'F')
          CALL U2MESS('F','ASSEMBLA_20')
        ENDIF
      ENDIF

101   CONTINUE
C
C---- RECUPERATION ADRESSES DE CONNEX: ICONX1, ICONX2  ET NBELM
C
      CALL DISMOI('F','NB_MA_MAILLA',MAILLA(1:8),'MAILLAGE',
     &             NBELM,KBID,IERC)
      IF (NBELM.GT.0) THEN
        CALL JEVEUO(MAILLA(1:8)//'.CONNEX','L',ICONX1)
        CALL JEVEUO(JEXATR(MAILLA(1:8)//'.CONNEX','LONCUM'),'L',ICONX2)
      END IF
C
C---- CREATION DES OBJETS ADNE ET ADLI SUR 'V'
C
      CALL JEEXIN(PREFIX//'.ADNE',IRET)
      IF (IRET.GT.0)   CALL JEDETR(PREFIX//'.ADNE')
      IF (IRET.GT.0)   CALL JEDETR(PREFIX//'.ADLI')
      CALL WKVECT(PREFIX//'.ADNE',' V V I',3*NLILI,IADNEM)
      CALL WKVECT(PREFIX//'.ADLI',' V V I',3*NLILI,IADLIE)
C---- ADNE(1)= NBELM
      ZI(IADNEM) = NBELM
      NBMO=0
      ILIMO=0
      DO 200 ILI = 2,NLILI
         CALL JENUNO(JEXNUM(K24LIL,ILI),NOMLI)
C
C---- CALCUL DU NBRE DE LIGRELS DE MODELE : NBMO ET DE ILIMO
C
         IF (NOMLI(9:15).EQ.'.MODELE') THEN
            NBMO = NBMO + 1
            IF (NBMO.EQ.1) ILIMO=ILI
            IF (NBMO.GT.1) CALL U2MESS('F','ASSEMBLA_21')
         END IF
         CALL JEEXIN(NOMLI(1:19)//'.NEMA',IRET)
         IF (IRET.NE.0) THEN
C
C---- ADNE(3*(ILI-1)+1)=NBRE DE MAILLES SUP DU LIGREL NOMLI
C
            CALL JELIRA(NOMLI(1:19)//'.NEMA','NUTIOC',NBSUP,K1BID)
            ZI(IADNEM+3* (ILI-1)) = NBSUP
            CALL JEVEUT(NOMLI(1:19)//'.NEMA','L',IAD)
            ZI(IADNEM+3* (ILI-1)+1) = IAD
            CALL JEVEUT(JEXATR(NOMLI(1:19)//'.NEMA','LONCUM'),'L',IAD)
            ZI(IADNEM+3* (ILI-1)+2) = IAD
         ELSE
            ZI(IADNEM+3* (ILI-1)) = 0
            ZI(IADNEM+3* (ILI-1)+1) = 2**30
            ZI(IADNEM+3* (ILI-1)+2) = 2**30
         END IF
C
C---- ADLI(3*(ILI-1)+1)=NBRE DE MAILLES DU LIGREL NOMLI
C
         CALL JEEXIN(NOMLI(1:19)//'.LIEL',IRET)
         IF (IRET.GT.0) THEN
           CALL JELIRA(NOMLI(1:19)//'.LIEL','NUTIOC',NBGR,K1BID)
           ZI(IADLIE+3* (ILI-1)) = NBGR
           CALL JEVEUT(NOMLI(1:19)//'.LIEL','L',IAD)
           ZI(IADLIE+3* (ILI-1)+1) = IAD
           CALL JEVEUT(JEXATR(NOMLI(1:19)//'.LIEL','LONCUM'),'L',IAD)
           ZI(IADLIE+3* (ILI-1)+2) = IAD
         ELSE
            ZI(IADLIE+3* (ILI-1)) = 0
            ZI(IADLIE+3* (ILI-1)+1) = 2**30
            ZI(IADLIE+3* (ILI-1)+2) = 2**30
         END IF
  200 CONTINUE
 9999 CONTINUE
      END
