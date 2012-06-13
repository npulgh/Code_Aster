      SUBROUTINE TELLME (CODMES,QUESTI,CHAR01,CHAR02,REPKZ,CODRET)
C
C ----------------------------------------------------------------------
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C ----------------------------------------------------------------------
C     RECHERCHE D'INFORMATIONS DIVERSES (OUAHHH !)
C     ------------------------------------------------------------------
C     IN:
C       CODMES : CODE DES MESSAGES A EMETTRE : 'F', 'A', ...
C       QUESTI : TEXTE PRECISANT LA QUESTION POSEE
C       CHAR01 : CHAINE NUMERO 1
C       CHAR02 : CHAINE NUMERO 2
C     OUT:
C       REPKZ  : REPONSE ( SI CHAINE DE CARACTERES )
C       CODRET   : CODE RETOUR (0--> OK, 1 --> PB)
C
C ----------------------------------------------------------------------
C
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
      INCLUDE 'jeveux.h'
      INTEGER CODRET
      CHARACTER*(*) CHAR01, CHAR02
      CHARACTER*(*) QUESTI, CODMES, REPKZ
C
C 0.2. ==> COMMUNS
C
C
C 0.3. ==> VARIABLES LOCALES
C
C
      INTEGER JVALE, IBID, IAUX, LONG, LTYP
C
      CHARACTER*19 NOMFON, NOMCAR
      CHARACTER*24 REPK, K24BID
      CHARACTER*24 VALK(2)
      CHARACTER*8  K8B, TYPE
C
C     ------------------------------------------------------------------
C====
C 1. EXPLORATION
C====
C
      CALL JEMARQ()
C
      CODRET = 0
      REPK = '??????'
C
C 1.1. ==> LA FONCTION DE NOM 'NOMFON' EST-ELLE DANS LA CARTE ?
C
      IF ( QUESTI.EQ.'NOM_FONCTION' ) THEN
         NOMCAR = CHAR01
         NOMFON = CHAR02
         CALL JEVEUO ( NOMCAR//'.VALE', 'L', JVALE )
         CALL JELIRA ( NOMCAR//'.VALE', 'TYPE', IBID, TYPE )
         CALL JELIRA ( NOMCAR//'.VALE', 'LTYP', LTYP, K8B)
         IF (TYPE(1:1).EQ.'K') THEN
           CALL JELIRA(NOMCAR//'.VALE','LONMAX',LONG,K8B)
           DO 11 , IAUX = 1 , LONG
             IF (LTYP.EQ.8) THEN
               K24BID = ZK8(JVALE+IAUX-1)
             ELSE IF (LTYP.EQ.24) THEN
               K24BID = ZK24(JVALE+IAUX-1)
             ELSE
               CALL ASSERT(.FALSE.)
             END IF
             IF ( K24BID(1:8) .EQ. NOMFON ) THEN
               REPK = 'OUI'
               GOTO 111
             ENDIF
   11      CONTINUE
           REPK = 'NON'
  111      CONTINUE
         ELSE
           CODRET = 1
            VALK(1) = NOMCAR
            VALK(2) = TYPE
            CALL U2MESK(CODMES,'UTILITAI4_88', 2 ,VALK)
         ENDIF
C
C 1.N. ==> QUESTION INCONNUE
C
      ELSE
        CODRET = 1
        K24BID = QUESTI
        CALL U2MESK(CODMES,'UTILITAI_49',1,K24BID)
      ENDIF
C
      REPKZ = REPK
      CALL JEDEMA()
C
      END
