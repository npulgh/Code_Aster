      SUBROUTINE MERIT2(MODELE,NCHAR,LCHAR,CARA,TIME,MATEL,PREFCH,
     &                  NUMERO,BASE)
      IMPLICIT REAL*8 (A-H,O-Z)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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

C     ARGUMENTS:
C     ----------
      INCLUDE 'jeveux.h'
      CHARACTER*8 MODELE,CARA
      CHARACTER*19 MATEL,PREFCH
      CHARACTER*(*) LCHAR(*)
      CHARACTER*24 TIME
      CHARACTER*1 BASE
      INTEGER NCHAR,NUMERO
C ----------------------------------------------------------------------

C     CALCUL DES MATRICES ELEMENTAIRES DE RIGIDITE THERMIQUE (2)
C        ( ISO_FACE, 'RIGI_THER_COEH_R/F' , 'RIGI_THER_PARO_R/F' )

C     LES RESUELEM PRODUITS S'APPELLENT :
C           PREFCH(1:8).ME000I , I=NUMERO+1,NUMERO+N

C     ENTREES:

C     LES NOMS QUI SUIVENT SONT LES PREFIXES UTILISATEUR K8:
C        MODELE : NOM DU MODELE
C        NCHAR  : NOMBRE DE CHARGES
C        LCHAR  : LISTE DES CHARGES
C        CARA   : CHAMP DE CARAC_ELEM
C        MATEL  : NOM DU MATR_ELEM (N RESUELEM) PRODUIT
C        PREFCH : PREFIXE DES NOMS DES RESUELEM STOCKES DANS MATEL
C        NUMERO : NUMERO D'ORDRE A PARTIR DUQUEL ON NOMME LES RESUELEM
C        TIME   : CHAMPS DE TEMPSR

C     SORTIES:
C        MATEL  : EST REMPLI.

C ----------------------------------------------------------------------

C     FONCTIONS EXTERNES:
C     -------------------

C     VARIABLES LOCALES:
C     ------------------


      CHARACTER*8 NOMCHA,LPAIN(4),LPAOUT(1),K8BID
      CHARACTER*16 OPTION
      CHARACTER*24 LIGREL(2),LCHIN(5),LCHOUT(1),CHGEOM,CHCARA(18)
      INTEGER IRET,ILIRES,IBID,ICHA
      LOGICAL EXIGEO,EXICAR
C ----------------------------------------------------------------------
      INTEGER NBCHMX
      PARAMETER (NBCHMX=2)
      INTEGER NLIGR(NBCHMX)
      CHARACTER*6 NOMPAR(NBCHMX),NOMCHP(NBCHMX),NOMOPT(NBCHMX)
      DATA NOMCHP/'.COEFH','.HECHP'/
      DATA NOMOPT/'_COEH_','_PARO_'/
      DATA NOMPAR/'PCOEFH','PHECHP'/
      DATA NLIGR/1,2/


C     -- ON VERIFIE LA PRESENCE PARFOIS NECESSAIRE DE CARA_ELEM
      CALL JEMARQ()
      IF (MODELE(1:1).NE.' ') THEN
      ELSE
        CALL U2MESS('F','CALCULEL3_50')
      END IF

      CALL MEGEOM(MODELE,LCHAR(1) (1:8),EXIGEO,CHGEOM)
      CALL MECARA(CARA,EXICAR,CHCARA)

      CALL JEEXIN(MATEL//'.RERR',IRET)
      IF (IRET.GT.0) THEN
        CALL JEDETR(MATEL//'.RERR')
        CALL JEDETR(MATEL//'.RELR')
      END IF
      CALL MEMARE('V',MATEL,MODELE,' ',CARA,'RIGI_THER')

      LPAOUT(1) = 'PMATTTR'
      LCHOUT(1) = PREFCH(1:8)//'.ME000'
      ILIRES = 0
      IF (LCHAR(1) (1:8).NE.'        ') THEN
        LIGREL(1) = MODELE(1:8)//'.MODELE'
        LPAIN(1) = 'PGEOMER'
        LCHIN(1) = CHGEOM
        LPAIN(2) = 'PTEMPSR'
        LCHIN(2) = TIME

        DO 20 ICHA = 1,NCHAR
          NOMCHA = LCHAR(ICHA)
          LIGREL(2) = NOMCHA(1:8)//'.CHTH.LIGRE'
          CALL DISMOI('F','TYPE_CHARGE',NOMCHA,'CHARGE',IBID,K8BID,IERD)
          IF (K8BID(5:7).EQ.'_FO') THEN
            OPTION = 'RIGI_THER_    _F'
            LPAIN(3) = '      F'
          ELSE
            OPTION = 'RIGI_THER_    _R'
            LPAIN(3) = '      R'
          END IF
          DO 10 K = 1,NBCHMX
            LCHIN(3) = NOMCHA//'.CHTH'//NOMCHP(K)//'.DESC'
            CALL JEEXIN(LCHIN(3),IRET3)
            IF (IRET3.GT.0) THEN
              OPTION(10:15) = NOMOPT(K)
              LPAIN(3) (1:6) = NOMPAR(K)
              ILIRES = ILIRES + 1
              CALL CODENT(ILIRES+NUMERO,'D0',LCHOUT(1) (12:14))
              CALL CALCUL('S',OPTION,LIGREL(NLIGR(K)),3,LCHIN,LPAIN,1,
     &                    LCHOUT,LPAOUT,BASE,'OUI')
              CALL REAJRE(MATEL,LCHOUT(1),BASE)
            END IF
   10     CONTINUE
   20   CONTINUE
      END IF
      CALL JEDEMA()
      END
