      SUBROUTINE VEDIME(MODELE,CHARGE,INFCHA,INSTAP,TYPRES,TYPESE,
     &                  NOPASE,VECELZ)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.

C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C ----------------------------------------------------------------------
C     CALCUL DES VECTEURS ELEMENTAIRES DES ELEMENTS DE LAGRANGE
C     PRODUIT UN VECT_ELEM DEVANT ETRE ASSEMBLE PAR LA ROUTINE ASASVE

C IN  MODELE  : NOM DU MODELE
C IN  CHARGE  : LISTE DES CHARGES
C IN  INFCHA  : INFORMATIONS SUR LES CHARGEMENTS
C IN  INSTAP  : INSTANT DU CALCUL
C IN  TYPESE  : TYPE DE SENSIBILITE
C                0 : CALCUL STANDARD, NON DERIVE
C                SINON : DERIVE (VOIR METYSE)
C . POUR UN CALCUL DE DERIVEE, ON A LES DONNEES SUIVANTES :
C IN  NOPASE  : NOM DU PARAMETRE SENSIBLE
C VAR/JXOUT  VECELZ  : VECT_ELEM RESULTAT.
C ----------------------------------------------------------------------
      IMPLICIT NONE

C 0.1. ==> ARGUMENTS

      INCLUDE 'jeveux.h'
      INTEGER TYPESE
      CHARACTER*(*) NOPASE
      CHARACTER*(*) VECELZ,TYPRES
      CHARACTER*24 MODELE,CHARGE,INFCHA
      REAL*8 INSTAP

C 0.2. ==> COMMUNS

C 0.3. ==> VARIABLES LOCALES

      CHARACTER*6 NOMPRO
      PARAMETER (NOMPRO='VEDIME')

      CHARACTER*8 NOMCH0,NOMCHS,NOMCHA
      CHARACTER*8 LPAIN(3),PAOUT,K8BID,NEWNOM
      CHARACTER*16 OPTION
      CHARACTER*19 VECELE
      CHARACTER*24 LIGRCH,LIGRCS,LCHIN(3),RESUEL,CHGEOM,CHTIME
      INTEGER IAUX,IRET,NCHAR,ILVE,JINF,JCHAR,ICHA,JNOLI,NBNOLI
      INTEGER NUMDI
      INTEGER EXICHA
      LOGICAL EXIGEO,BIDON
      COMPLEX*16 CBID
C ----------------------------------------------------------------------
      CALL JEMARQ()
      NEWNOM = '.0000000'
      VECELE = VECELZ
      IF (VECELE.EQ.' ') THEN
        VECELE = '&&'//NOMPRO
      END IF
      RESUEL = '&&'//NOMPRO//'.???????'

C     -- BIDON=.TRUE. -> IL N'Y A PAS DE CHARGE
C     -------------------------------------
      BIDON = .TRUE.
      CALL JEEXIN(CHARGE,IRET)
      IF (IRET.NE.0) THEN
        CALL JELIRA(CHARGE,'LONMAX',NCHAR,K8BID)
        IF (NCHAR.NE.0) THEN
          BIDON = .FALSE.
          CALL JEVEUO(CHARGE,'L',JCHAR)
          CALL JEVEUO(INFCHA,'L',JINF)
        END IF
      END IF

C     -- ALLOCATION DU VECT_ELEM RESULTAT :
C     -------------------------------------
      CALL DETRSD('VECT_ELEM',VECELE)
      CALL MEMARE('V',VECELE,MODELE(1:8),' ',' ','CHAR_MECA')
      CALL REAJRE(VECELE,' ','V')
      IF (BIDON) GO TO 40

      CALL MEGEOM(MODELE(1:8),ZK24(JCHAR) (1:8),EXIGEO,CHGEOM)

      IF (TYPRES.EQ.'R') THEN
        PAOUT = 'PVECTUR'
      ELSE
        PAOUT = 'PVECTUC'
      END IF
      LPAIN(2) = 'PGEOMER'
      LCHIN(2) = CHGEOM
      LPAIN(3) = 'PTEMPSR'

      CHTIME = '&&'//NOMPRO//'.CH_INST_R'
      CALL MECACT('V',CHTIME,'MODELE',MODELE(1:8)//'.MODELE','INST_R  ',
     &            1,'INST',IAUX,INSTAP,CBID,K8BID)
      LCHIN(3) = CHTIME

      ILVE = 0
      DO 30 ICHA = 1,NCHAR
        NUMDI = ZI(JINF+ICHA)
        IF ((NUMDI.GT.0) .AND. (NUMDI.LE.3)) THEN
          NOMCH0 = ZK24(JCHAR+ICHA-1) (1:8)
          LIGRCH = NOMCH0//'.CHME.LIGRE'
          IF (TYPESE.NE.0) THEN
            CALL PSGENC(NOMCH0,NOPASE,NOMCHS,EXICHA)

C           ATTENTION : DANS LE CAS D'UN CALCUL DE SENSIBILITE, ON
C           UTILISERA LE LIGREL DU CHARGEMENT STANDARD. POUR CELA ON
C           REMPLACE LE NOM JEVEUX STOCKE DANS LE CHARGEMENT SENSIBLE
C           PAR LE NOM STANDARD, LIGRCH. EVIDEMMENT, A LA FIN DU
C           TRAITEMENT, ON REMETTRA LE VRAI NOM, SAUVEGARDE DANS LIGRCS.

            IF (EXICHA.EQ.0) THEN
              CALL JELIRA(NOMCHS//'.CHME.CIMPO.NOLI','LONMAX',NBNOLI,
     &                    K8BID)
              CALL JEVEUO(NOMCHS//'.CHME.CIMPO.NOLI','E',JNOLI)
              LIGRCS = ZK24(JNOLI)
              DO 10,IAUX = 0,NBNOLI - 1
                ZK24(JNOLI+IAUX) = LIGRCH
   10         CONTINUE
              NOMCHA = NOMCHS
            END IF
          ELSE
            EXICHA = 0
            NOMCHA = NOMCH0
          END IF
          IF (EXICHA.EQ.0) THEN
            LCHIN(1) = NOMCHA//'.CHME.CIMPO.DESC'
            IF (NUMDI.EQ.1) THEN
              IF (TYPRES.EQ.'R') THEN
                OPTION = 'MECA_DDLI_R'
                LPAIN(1) = 'PDDLIMR'
              ELSE
                OPTION = 'MECA_DDLI_C'
                LPAIN(1) = 'PDDLIMC'
              END IF
            ELSE IF (NUMDI.EQ.2) THEN
              OPTION = 'MECA_DDLI_F'
              LPAIN(1) = 'PDDLIMF'
            ELSE IF (NUMDI.EQ.3) THEN
              OPTION = 'MECA_DDLI_F'
              LPAIN(1) = 'PDDLIMF'
            END IF
            ILVE = ILVE + 1

            CALL GCNCO2(NEWNOM)
            RESUEL(10:16) = NEWNOM(2:8)
            CALL CORICH('E',RESUEL,ICHA,IAUX)

            CALL CALCUL('S',OPTION,LIGRCH,3,LCHIN,LPAIN,1,RESUEL,PAOUT,
     &                  'V','OUI')
            CALL REAJRE(VECELE,RESUEL,'V')
C           ON REMET LE VRAI NOM DU LIGREL POUR LE CHARGEMENT SENSIBLE :
            IF (TYPESE.NE.0) THEN
              DO 20,IAUX = 0,NBNOLI - 1
                ZK24(JNOLI+IAUX) = LIGRCS
   20         CONTINUE
            END IF
          END IF
        END IF
   30 CONTINUE

   40 CONTINUE

      VECELZ = VECELE//'.RELR'

      CALL JEDEMA()
      END
