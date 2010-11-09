      SUBROUTINE RESLGN(LIGREL,OPTION,ERREE,ERREN)
      IMPLICIT NONE
      CHARACTER*(*) LIGREL,ERREE,ERREN
C----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 08/11/2010   AUTEUR PELLET J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
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

C     BUT:   CALCUL DE L'OPTION : 'ERRE_ELNO_ELEM' ET 'QIRE_ELNO_ELEM'
C     ----

C IN  : LIGREL : NOM DU LIGREL
C IN  : ERREE  : NOM DU CHAM_ELEM ERREUR PAR ELEMENT
C OUT : ERREN  : NOM DU CHAM_ELEM_ERREUR PRODUIT AUX NOEUDS

C ......................................................................

      CHARACTER*8 LPAIN(1),LPAOUT(1)
      CHARACTER*16 OPTION
      CHARACTER*24 LCHIN(1),LCHOUT(1)

      LPAIN(1) = 'PERREUR'
      LCHIN(1) = ERREE

      LPAOUT(1) = 'PERRENO'
      LCHOUT(1) = ERREN

      CALL CALCUL('S',OPTION,LIGREL,1,LCHIN,LPAIN,1,LCHOUT,LPAOUT,'G',
     &               'OUI')

      END
