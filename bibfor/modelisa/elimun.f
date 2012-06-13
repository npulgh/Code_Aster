      SUBROUTINE ELIMUN(NOMA  ,NOMO  ,MOTFAC,NZOCU ,NBGDCU,
     &                  COMPCU,NOPONO,NOLINO,LISNOE,POINOE,
     &                  NNOCO)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
C
      IMPLICIT      NONE
      INCLUDE 'jeveux.h'
      CHARACTER*8   NOMA,NOMO
      CHARACTER*16  MOTFAC
      INTEGER       NZOCU
      CHARACTER*24  NBGDCU
      CHARACTER*24  COMPCU
      CHARACTER*24  NOPONO
      CHARACTER*24  NOLINO
      CHARACTER*24  LISNOE
      CHARACTER*24  POINOE
      INTEGER       NNOCO
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (LIAISON_UNILATER - LECTURE)
C
C ELIMINATION AU SEIN DE CHAQUE SURFACE DE CONTACT POTENTIELLE DES
C NOEUDS ET MAILLES REDONDANTS. MODIFICATION DES POINTEURS ASSOCIES.
C      
C ----------------------------------------------------------------------
C
C
C IN  NOMA   : NOM DU MAILLAGE
C IN  NOMO   : NOM DU MODELE
C IN  MOTFAC : MOT-CLEF FACTEUR POUR LIAISON UNILATERALE
C IN  NZOCU  : NOMBRE DE ZONES DE LIAISON_UNILATERALE
C IN  NBGDCU : NOM JEVEUX DE LA SD INFOS POINTEURS GRANDEURS
C IN  COMPCU : NOM JEVEUX DE LA SD CONTENANT LES GRANDEURS DU MEMBRE
C              DE GAUCHE
C IN  NOPONO : NOM DE L'OBJET CONTENANT LE VECTEUR D'INDIRECTION
C IN  NOLINO : NOM DE L'OBJET CONTENANT LA LISTE DES NOEUDS
C IN  POINOE : NOM DE L'OBJET CONTENANT LE VECTEUR D'INDIRECTION
C               DES NOEUDS APRES NETTOYAGE
C IN  LISNOE : NOM DE L'OBJET CONTENANT LES NOEUDS APRES NETTOYAGE
C IN  NBNOE  : NOMBRE DE NOEUDS DANS LA LISTE RESULTANTE
C                VAUT NBNOE = NBTOT-NBSUP
C I/O NNOCO  : NOMBRE DE TOTAL DE NOEUDS POUR TOUTES LES OCCURRENCES
C
C
C
C
      INTEGER       JDEBUT,JUELIM,JDECAL,JDECAT
      INTEGER       NBELIM
      CHARACTER*1   K1BID
      CHARACTER*8   K8BLA,CMP,NOMNOE
      INTEGER       I,J,ICMP,IZONE,INO,NUMNO1,NUMNO2
      INTEGER       NBNO,NBSUP,NB,NBCMP,NTSUP
      INTEGER       N1,N2,N3
      INTEGER       JNL,JNP,JPOI,JNOE
      CHARACTER*24  NELIM
      INTEGER       JELIM
      INTEGER       JNBGD,JCMPG
      INTEGER       EXIST
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- ACCES SD
C 
      CALL JEVEUO(NOLINO,'E',JNL)
      CALL JEVEUO(NOPONO,'L',JNP)
      CALL JEVEUO(NBGDCU,'L',JNBGD)
      CALL JEVEUO(COMPCU,'L',JCMPG)
C
      NTSUP = 0
      K8BLA = ' '
      NELIM = '&&ELIMUN.ELIM'
C
C --- CREATION DU POINTEUR
C
      CALL WKVECT(POINOE,'V V I',NZOCU+1,JPOI  )  
      ZI(JPOI) = 1
C
      DO 1000 IZONE=1,NZOCU
C
C --- VECTEUR CONTENANT LES NOEUDS ZONE 
C
        NBNO   = ZI(JNP+IZONE) - ZI(JNP+IZONE-1)
        JDEBUT = ZI(JNP+IZONE-1)
        N1     = 0
        N2     = 0
        N3     = 0
C
C --- ELIMINATION DES PURS DOUBLONS
C
        DO 10 I=1,NBNO
          NUMNO1 = ZI(JNL-2+JDEBUT+I)
          IF (NUMNO1.NE.0) THEN
            DO 11 J=I+1,NBNO
              NUMNO2 = ZI(JNL-2+JDEBUT+J)
              IF ((NUMNO1.EQ.NUMNO2).AND.(NUMNO2.NE.0)) THEN
                ZI(JNL-2+JDEBUT+J) = 0
                N1 = N1 + 1
              ENDIF
   11       CONTINUE
          ENDIF
   10   CONTINUE
C
C --- RECUPERATION INFOS SANS_NOEUD, SANS_GROUP_NO
C
        CALL PALINO(NOMA,MOTFAC,'SANS_GROUP_NO','SANS_NOEUD',IZONE,
     &              NELIM)
        CALL JEVEUO(NELIM,'L',JUELIM)
        NBELIM = ZI(JUELIM)
C
C --- ELIMINATION DES SANS_GROUP_NO, SANS_NOEUD
C
        CALL JELIRA(NELIM,'LONMAX',NBELIM,K1BID)
        CALL JEVEUO(NELIM,'E',JELIM)
        DO 20 I=1,NBELIM
          NUMNO1 = ZI(JUELIM-1+I)
          IF (NUMNO1.NE.0) THEN
            DO 21 J=1,NBNO
              NUMNO2 = ZI(JNL-2+JDEBUT+J)
              IF ((NUMNO1.EQ.NUMNO2).AND.(NUMNO2.NE.0)) THEN
                ZI(JNL-2+JDEBUT+J) = 0
                N2 = N2 + 1
              ENDIF
   21       CONTINUE
          ENDIF
   20   CONTINUE
C
C --- ELIMINATION DES NOEUDS NE COMPORTANT AUCUNE DES GRANDEURS
C
        NBCMP  = ZI(JNBGD+IZONE) - ZI(JNBGD+IZONE-1)
        JDECAT = ZI(JNBGD+IZONE-1)

        DO 30 INO=1,NBNO
          NUMNO1 = ZI(JNL-2+JDEBUT+INO)
          IF (NUMNO1.NE.0) THEN
            CALL JENUNO(JEXNUM(NOMA//'.NOMNOE',NUMNO1),NOMNOE)
            NB = 0
            DO 31 ICMP=1,NBCMP
               
              CMP = ZK8(JCMPG-1+JDECAT+ICMP-1)
              CALL EXISCP(CMP,K8BLA,NOMO,
     &                    1,'NUM',K8BLA,NUMNO1,
     &                    EXIST)
              IF (EXIST.EQ.0) THEN
                NB = NB + 1
              ENDIF
   31       CONTINUE
            IF (NB.EQ.NBCMP) THEN
              ZI(JNL-2+JDEBUT+INO) = 0
              N3 = N3 + 1
            ENDIF
          ENDIF
   30   CONTINUE
C
C --- NOMBRE DE NOEUDS A SUPPRIMER
C
        NBSUP = N1 + N2 + N3
        NTSUP = NTSUP + NBSUP
C
C --- MAJ VECTEUR POINTEUR INDIRECT (POINOE)
C
        ZI(JPOI+IZONE) = ZI(JPOI+IZONE-1) + NBNO - NBSUP
        IF (NBNO.EQ.NBSUP) THEN
          CALL U2MESS('F','UNILATER_48')
        ENDIF
 1000 CONTINUE
C
C --- CREATION DU VECTEUR RESULTANT
C
      NNOCO  = NNOCO - NTSUP
      CALL WKVECT(LISNOE,'V V I',NNOCO,JNOE)
C
C --- ELIMINATION EFFECTIVE DES NOEUDS
C
      JDECAL = 0
      DO 50 IZONE = 1,NZOCU
        NBNO   = ZI(JNP+IZONE) - ZI(JNP+IZONE-1)
        JDEBUT = ZI(JNP+IZONE-1)
        DO 51 INO=1,NBNO
          NUMNO1 = ZI(JNL-2+JDEBUT+INO)
          IF (NUMNO1.NE.0) THEN
            ZI(JNOE+JDECAL) = NUMNO1
            JDECAL = JDECAL +1
          ENDIF
   51   CONTINUE
   50 CONTINUE
C
      CALL JEDETR(NELIM)
C
      CALL JEDEMA()

      END
