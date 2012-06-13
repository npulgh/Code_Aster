      SUBROUTINE MEAMAC(MODELZ,NCHA,LCHA,MATE,MATELZ)
      IMPLICIT REAL*8 (A-H,O-Z)
      INCLUDE 'jeveux.h'
      INTEGER                  NCHA
      CHARACTER*(*)     MODELZ,          MATE,MATELZ
      CHARACTER*8                   LCHA(*)
C ----------------------------------------------------------------------
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C
C*    CALCUL DES MATRICES ELEMENTAIRES D'AMORTISSEMENT ACOUSTIQUE
C      MATEL:
C*           ( ISO_FACE, 'AMOR_ACOU '   )
C
C     ENTREES:
C
C     LES NOMS QUI SUIVENT SONT LES PREFIXES UTILISATEUR K8:
C        MODELZ : NOM DU MODELE
C*       NCHA   : NOMBRE DE CHARGES
C*       LCHA   : LISTE  DES CHARGES
C*       MATE   : CARTE DE MATERIAU CODE
C        MATELZ : NOM  DU  MATELE (N RESUELEM) PRODUIT
C*                ( ISO_FACE, 'AMOR_ACOU '   )
C
C     SORTIES:
C        MATELZ    : LE MATELE EST REMPLI.
C
C ----------------------------------------------------------------------
C
C     FONCTIONS EXTERNES:
C     -------------------
C*
C
C     VARIABLES LOCALES:
C     ------------------
C
      CHARACTER*8 K8BID, MODELE
      CHARACTER*19 MATEL
C
      CALL JEMARQ()
      MODELE = MODELZ
      MATEL  = MATELZ
C
C*    -- AMORTISSEMENT CORRESPONDANT AUX ELEMENTS ISO_FACE
      CALL MEAMA2(MODELE,NCHA,LCHA,MATE,
     &           '&MEAMAC2           ',MATEL)
C
C*    -- ON RECOPIE LES .RELR DE &MEAMAC2 DANS MATEL.
C**
      CALL JELIRA('&MEAMAC2           .RELR','LONUTI',LONG2,K8BID)
      CALL JEVEUO('&MEAMAC2           .RELR','L',JLIRE2)
C**
      CALL JEEXIN(MATEL//'.RERR',IRET)
      IF (IRET.GT.0) THEN
        CALL JEDETR(MATEL//'.RERR')
        CALL JEDETR(MATEL//'.RELR')
      END IF

      CALL MEMARE('G',MATEL,MODELE,MATE,' ','AMOR_ACOU')

      DO 1,I = 1,LONG2
        CALL REAJRE(MATEL,ZK24(JLIRE2-1+I),'G')
    1 CONTINUE
      CALL JEDETC('G','MEAMAC2',1)
C
      MATELZ = MATEL
      CALL JEDEMA()
      END
