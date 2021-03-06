# coding=utf-8
# ======================================================================
# COPYRIGHT (C) 1991 - 2017  EDF R&D                  WWW.CODE-ASTER.ORG
# THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
# IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
# THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
# (AT YOUR OPTION) ANY LATER VERSION.
#
# THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
# WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
# MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
# GENERAL PUBLIC LICENSE FOR MORE DETAILS.
#
# YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
# ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
#    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
# ======================================================================
# person_in_charge: kyrylo.kazymyrenko at edf.fr
# ----------------------------------------------------------------------
#  POST_CZM_FISS :
#  ---------------
#  OPTION = 'LONGUEUR'
#    - CALCUL DE LA LONGUEUR DES FISSURES COHESIVES 2D
#    - PRODUIT UNE TABLE
#  OPTION = 'TRIAXIALITE'
#    - CALCUL DE LA TRIAXIALITE DANS LES ELEMENTS MASSIFS CONNECTES A
#      L'INTERFACE COHESIVE
#    - PRODUIT UNE CARTE
# ----------------------------------------------------------------------

from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


def post_czm_fiss_prod(self,OPTION,**args):
  if OPTION == 'LONGUEUR'    : return table_sdaster
  if OPTION == 'TRIAXIALITE' : return carte_sdaster
  raise AsException("type de concept resultat non prevu")

POST_CZM_FISS=MACRO(

  nom="POST_CZM_FISS",
  op=OPS('Macro.post_czm_fiss_ops.post_czm_fiss_ops'),
  sd_prod=post_czm_fiss_prod,
  reentrant='n',
  fr=tr("Post-Traiement scpécifiques aux modèles CZM"),

  OPTION = SIMP(statut='o',typ='TXM',max=1,into=("LONGUEUR","TRIAXIALITE"),),

  RESULTAT = SIMP(statut='o',typ=evol_noli,max=1,),

  b_longueur =BLOC(
    condition  = """equal_to("OPTION", 'LONGUEUR') """,
    GROUP_MA   = SIMP(statut='o',typ=grma,validators=NoRepeat(),max='**'),
    POINT_ORIG = SIMP(statut='o',typ='R',min=2,max=2),
    VECT_TANG  = SIMP(statut='o',typ='R',min=2,max=2),
                  ),

                    )
