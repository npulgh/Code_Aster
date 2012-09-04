      SUBROUTINE DISMCP(QUESTI,NOMOBZ,REPI,REPKZ,IERD)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 04/09/2012   AUTEUR PELLET J.PELLET 
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
      IMPLICIT NONE
C     --     DISMOI(CHAMP)  CHAPEAU DE :
C       CHAM_NO, CHAM_NO_S, CARTE, CHAM_ELEM, CHAM_ELEM_S,
C       RESUELEM, CHAM_GENE

      INCLUDE 'jeveux.h'
      INTEGER REPI,IERD
      CHARACTER*(*) QUESTI
      CHARACTER*(*) REPKZ,NOMOBZ
      CHARACTER*32 REPK
      CHARACTER*19 NOMOB
C ----------------------------------------------------------------------
C     IN:
C       QUESTI : TEXTE PRECISANT LA QUESTION POSEE
C       NOMOBZ : NOM D'UN OBJET DE TYPE CHAMP
C     OUT:
C       REPI   : REPONSE ( SI ENTIERE )
C       REPKZ  : REPONSE ( SI CHAINE DE CARACTERES )
C       IERD   : CODE RETOUR (0--> OK, 1 --> PB)

C ----------------------------------------------------------------------
C     VARIABLES LOCALES:
C     ------------------
      CHARACTER*4 TYCH
      INTEGER IBID,IEXI

C DEB-------------------------------------------------------------------
      REPK  = ' '
      REPI  = 0
      IERD = 0

      NOMOB = NOMOBZ

      CALL JEEXIN(NOMOB(1:19)//'.DESC',IEXI)
      IF (IEXI.GT.0) THEN
        CALL JELIRA(NOMOB(1:19)//'.DESC','DOCU',IBID,TYCH)
      ELSE
        CALL JEEXIN(NOMOB(1:19)//'.CELD',IEXI)
        IF (IEXI.GT.0) THEN
          CALL JELIRA(NOMOB(1:19)//'.CELD','DOCU',IBID,TYCH)
        ELSE
          CALL JEEXIN(NOMOB(1:19)//'.CESD',IEXI)
          IF (IEXI.GT.0) THEN
            TYCH='CES'
          ELSE
            CALL JEEXIN(NOMOB(1:19)//'.CNSD',IEXI)
            IF (IEXI.GT.0) THEN
              TYCH='CNS'
            ELSE
              REPK = ' '
              GO TO 10
            END IF
          END IF
        END IF
      END IF


      IF (TYCH.EQ.'CHNO') THEN
        CALL DISMCN(QUESTI,NOMOB,REPI,REPK,IERD)
      ELSE IF (TYCH.EQ.'CART') THEN
        CALL DISMCA(QUESTI,NOMOB,REPI,REPK,IERD)
      ELSE IF (TYCH.EQ.'CHML') THEN
        CALL DISMCE(QUESTI,NOMOB,REPI,REPK,IERD)
      ELSE IF (TYCH.EQ.'RESL') THEN
        CALL DISMRE(QUESTI,NOMOB,REPI,REPK,IERD)
      ELSE IF (TYCH.EQ.'VGEN') THEN
        CALL DISMCG(QUESTI,NOMOB,REPI,REPK,IERD)
      ELSE IF (TYCH.EQ.'CNS') THEN
        CALL DISMNS(QUESTI,NOMOB,REPI,REPK,IERD)
      ELSE IF (TYCH.EQ.'CES') THEN
        CALL DISMES(QUESTI,NOMOB,REPI,REPK,IERD)
      ELSE
        IERD = 1
      END IF

   10 CONTINUE
      REPKZ = REPK
      END
