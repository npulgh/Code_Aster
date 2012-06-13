      SUBROUTINE UTIMS3(COMM,ICOMM,SCH1,IPOS,BASE)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
      IMPLICIT NONE
C     --
C     ARGUMENTS:
C     ----------
      INCLUDE 'jeveux.h'
      CHARACTER*(*) COMM,SCH1,BASE
      INTEGER IPOS,ICOMM
C ----------------------------------------------------------------------
C BUT:
C   IMPRIMER SUR LE FICHIER 'MESSAGE' LE RESUME DES OBJETS JEVEUX (K24)
C   AYANT LA CHAINE SCH1 EN POSITION IPOS DANS LEURS NOMS.


C IN:
C   COMM   : COMMENTAIRE DE DEBUT DE CHAQUE LIGNE (K8)
C  ICOMM   : ENTIER COMMENTAIRE DE DEBUT DE CHAQUE LIGNE
C   SCH1   : CHAINE DE CARACTERES CHERCHEE
C   IPOS   : DEBUT DE LA CHAINE DE CARACTERES A CHERCHER
C   BASE   : 'G','V','L',OU ' '(TOUTES)

C ----------------------------------------------------------------------
C     VARIABLES LOCALES:
C     ------------------
      CHARACTER*24 OB1,CHAIN2,FICOU
      CHARACTER*8 KBID,COMM2
      CHARACTER*1 BAS2
      INTEGER LONG,IFM,IUNIFI,NBVAL,NBOBJ,IALIOB,I,IRET


      CALL JEMARQ()
      BAS2 = BASE
      COMM2 = COMM


C     --QUELQUES VERIFICATIONS:
C     -------------------------
      LONG = LEN(SCH1)
      IF (LEN(SCH1).GT.24) THEN
        CALL U2MESS('F','UTILITAI5_42')
      END IF
      IF ((IPOS.LT.0) .OR. (IPOS.GT.24)) THEN
        CALL U2MESS('F','UTILITAI5_43')
      END IF
      IF (IPOS+LEN(SCH1).GT.25) THEN
        CALL U2MESS('F','UTILITAI5_44')
      END IF


C     -- DETERMINATION DU NOMBRE DES OBJETS TROUVES :
C    ------------------------------------------------
      IF (LONG.EQ.24) THEN
        CALL JEEXIN(SCH1,IRET)
        IF (IRET.GT.0) THEN
          NBOBJ = 1
        ELSE
          NBOBJ = 0
        END IF
      ELSE
        CALL JELSTC(BAS2,SCH1,IPOS,0,KBID,NBVAL)
        NBOBJ = -NBVAL
      END IF


C     -- ECRITURE DE L'ENTETE :
C    --------------------------
      FICOU = 'MESSAGE'
      IFM = IUNIFI(FICOU)
      CHAIN2 = '????????????????????????'
      CHAIN2(IPOS:IPOS-1+LONG) = SCH1
      WRITE (IFM,*) ' '
      WRITE (IFM,*) '#AJ1 ====> UTIMS3 DE LA STRUCTURE DE DONNEE : ',
     &  CHAIN2
      WRITE (IFM,*) '#AJ1 NOMBRE D''OBJETS (OU COLL.) TROUVES :',NBOBJ
      IF (NBOBJ.EQ.0) GO TO 20


C     -- RECHERCHE DES NOMS DES OBJETS VERIFIANT LE CRITERE:
C    -------------------------------------------------------
      CALL WKVECT('&&UTIMS3.LISTE','V V K24',NBOBJ,IALIOB)
      IF (LONG.EQ.24) THEN
        ZK24(IALIOB-1+1) = SCH1
      ELSE
        CALL JELSTC(BAS2,SCH1,IPOS,NBOBJ,ZK24(IALIOB),NBVAL)
      END IF

C     -- ON TRIE PAR ORDRE ALPHABETIQUE:
      CALL UTTR24(ZK24(IALIOB),NBOBJ)


C     -- ECRITURE D'UNE LIGNE D'INFO POUR CHAQUE OBJET
C    -------------------------------------------------------
      WRITE (IFM,1001) COMM2,'ICOMM','#AJ2>','NOMOBJ','<','LONUTI',

     &  'LONMAX','TYPE','IRET','SOMMI','RESUME','SOMMR'
      DO 10 I = 1,NBOBJ
        OB1 = ZK24(IALIOB-1+I)
        CALL DBGOBJ(OB1,'OUI',IFM,'&&UTIMS3')
   10 CONTINUE


      CALL JEDETR('&&UTIMS3.LISTE')
   20 CONTINUE
      CALL JEDEMA()

 1001 FORMAT (A8,A4,A5,A24,A1,A8,A8,A5,A5,A10,A10,A15)
      END
