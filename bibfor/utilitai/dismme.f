      SUBROUTINE DISMME(QUESTI,NOMOBZ,REPI,REPKZ,IERD)
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
C     --     DISMOI(MATR_ELEM OU VECT_ELEM)
C     ARGUMENTS:
C     ----------
      INCLUDE 'jeveux.h'
      INTEGER REPI,IERD
      CHARACTER*(*) QUESTI
      CHARACTER*(*) NOMOBZ, REPKZ
      CHARACTER*32  REPK
      CHARACTER*19  NOMOB
C ----------------------------------------------------------------------
C    IN:
C       QUESTI : TEXTE PRECISANT LA QUESTION POSEE
C       NOMOBZ : NOM D'UN OBJET DE CONCEPT MATR_ELEM
C    OUT:
C       REPI   : REPONSE ( SI ENTIERE )
C       REPKZ  : REPONSE ( SI CHAINE DE CARACTERES )
C       IERD   : CODE RETOUR (0--> OK, 1 --> PB)
C
C ----------------------------------------------------------------------
C     VARIABLES LOCALES:
C     ------------------
      CHARACTER*7  TYPMAT,KMPIC,ZERO
      INTEGER      IRET,I,I1,IALIRE,IAREFE,NBRESU,IEXI
      CHARACTER*8 MO,PARTIT
      CHARACTER*8 KBID
C
C
C
      CALL JEMARQ()
      REPK  = ' '
      REPI  = 0
      IERD = 0

      NOMOB = NOMOBZ
      CALL JEVEUO(NOMOB//'.RERR','L',IAREFE)
      MO = ZK24(IAREFE-1+1)(1:8)
C
      IF (QUESTI.EQ.'NOM_MODELE') THEN
         REPK = MO

      ELSE IF (QUESTI.EQ.'TYPE_MATRICE') THEN
         REPK='SYMETRI'
         CALL JEEXIN(NOMOB//'.RELR', IRET)
         IF (IRET.GT.0) THEN
           CALL JELIRA(NOMOB//'.RELR','LONUTI',NBRESU,KBID)
           IF(NBRESU.GT.0)CALL JEVEUO(NOMOB//'.RELR','L',IALIRE)
           DO 1, I=1,NBRESU
             CALL JEEXIN(ZK24(IALIRE-1+I)(1:19)//'.NOLI',IEXI)
             IF (IEXI.EQ.0) GOTO 1
             CALL DISMRE(QUESTI,ZK24(IALIRE-1+I),REPI,TYPMAT,I1)
             IF ((I1.EQ.0).AND.(TYPMAT.EQ.'NON_SYM')) THEN
                REPK='NON_SYM'
                GO TO 9999
             END IF
 1         CONTINUE
         ENDIF

      ELSE IF (QUESTI.EQ.'ZERO') THEN
         REPK='OUI'
         CALL JEEXIN(NOMOB//'.RELR', IRET)
         IF (IRET.GT.0) THEN
           CALL JELIRA(NOMOB//'.RELR','LONUTI',NBRESU,KBID)
           IF(NBRESU.GT.0)CALL JEVEUO(NOMOB//'.RELR','L',IALIRE)
           DO 4, I=1,NBRESU
             CALL JEEXIN(ZK24(IALIRE-1+I)(1:19)//'.NOLI',IEXI)
             IF (IEXI.EQ.0) GOTO 4
             CALL DISMRE(QUESTI,ZK24(IALIRE-1+I),REPI,ZERO,I1)
             IF ((I1.EQ.0).AND.(ZERO.EQ.'NON')) THEN
                REPK='NON'
                GOTO 9999
             END IF
 4         CONTINUE
         ENDIF

      ELSE IF (QUESTI.EQ.'PARTITION') THEN
         REPK=' '
         CALL JEEXIN(NOMOB//'.RELR', IRET)
         IF (IRET.GT.0) THEN
           CALL JELIRA(NOMOB//'.RELR','LONUTI',NBRESU,KBID)
           IF (NBRESU.GT.0) CALL JEVEUO(NOMOB//'.RELR','L',IALIRE)
           DO 2, I=1,NBRESU
             CALL JEEXIN(ZK24(IALIRE-1+I)(1:19)//'.NOLI',IEXI)
             IF (IEXI.EQ.0) GOTO 2
             CALL DISMRE(QUESTI,ZK24(IALIRE-1+I),REPI,PARTIT,I1)
             IF (PARTIT.NE.' '.AND.REPK.EQ.' ') REPK=PARTIT
             IF (PARTIT.NE.' ') CALL ASSERT(REPK.EQ.PARTIT)
 2         CONTINUE
         ENDIF

      ELSE IF (QUESTI.EQ.'MPI_COMPLET') THEN
         REPK=' '
         CALL JEEXIN(NOMOB//'.RELR', IRET)
         IF (IRET.GT.0) THEN
           CALL JELIRA(NOMOB//'.RELR','LONUTI',NBRESU,KBID)
           IF (NBRESU.GT.0) CALL JEVEUO(NOMOB//'.RELR','L',IALIRE)
           DO 3, I=1,NBRESU
             CALL JEEXIN(ZK24(IALIRE-1+I)(1:19)//'.NOLI',IEXI)
             IF (IEXI.EQ.0) GOTO 3
             CALL DISMRE(QUESTI,ZK24(IALIRE-1+I),REPI,KMPIC,I1)
             IF (I.EQ.1) THEN
                REPK=KMPIC
             ELSE
                CALL ASSERT(REPK.EQ.KMPIC)
             ENDIF
 3         CONTINUE
         ENDIF

      ELSE IF (QUESTI.EQ.'CHAM_MATER') THEN
         REPK=ZK24(IAREFE-1+4)

      ELSE IF (QUESTI.EQ.'CARA_ELEM') THEN
         REPK=ZK24(IAREFE-1+5)

      ELSE IF (QUESTI.EQ.'NOM_MAILLA') THEN
         CALL DISMMO(QUESTI,MO,REPI,REPK,IERD)

      ELSE IF (QUESTI.EQ.'PHENOMENE') THEN
         CALL DISMMO(QUESTI,MO,REPI,REPK,IERD)

      ELSE IF (QUESTI.EQ.'SUR_OPTION') THEN
         REPK= ZK24(IAREFE-1+2)(1:16)

      ELSE IF (QUESTI.EQ.'NB_SS_ACTI') THEN
         IF(ZK24(IAREFE-1+3).EQ.'OUI_SOUS_STRUC') THEN
           CALL DISMMO(QUESTI,MO,REPI,REPK,IERD)
         ELSE
            REPI= 0
         END IF
      ELSE
         IERD=1
      END IF
C
 9999 CONTINUE
      REPKZ = REPK
      CALL JEDEMA()
      END
