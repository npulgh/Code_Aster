      SUBROUTINE OP0088()
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF SOUSTRUC  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
      IMPLICIT REAL*8 (A-H,O-Z)
C     COMMANDE:  DEFI_MAILLAGE
C
      INCLUDE 'jeveux.h'
      CHARACTER*8 NOMU
      CHARACTER*16 KBI1,KBI2
C
      CALL INFMAJ()
      CALL GETRES(NOMU,KBI1,KBI2)
C
C     --TRAITEMENT DU MOT CLEF 'DEFI_SUPER_MAILLE'
      CALL SSDMDM(NOMU)
C
C     --TRAITEMENT DES MOTS CLEF 'RECO_GLOBAL' ET 'RECO_SUPER_MAILLE'
      CALL SSDMRC(NOMU)
      CALL SSDMRG(NOMU)
      CALL SSDMRM(NOMU)
C
C     --TRAITEMENT DU MOT CLEF 'DEFI_NOEUD'
      CALL SSDMDN(NOMU)
C
C     --TRAITEMENT DU MOT CLEF 'DEFI_GROUP_NO'
      CALL SSDMGN(NOMU)
C
C     --ON TERMINE LE MAILLAGE :
      CALL SSDMTE(NOMU)
C
      CALL CARGEO ( NOMU )
C
      END
