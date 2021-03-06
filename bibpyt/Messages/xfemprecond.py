# coding=utf-8
# ======================================================================
# COPYRIGHT (C) 1991 - 2016  EDF R&D                  WWW.CODE-ASTER.ORG
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
# person_in_charge: patrick.massin at edf.fr


cata_msg = {

    1: _(u"""
  Alarme émise par le pré-conditionneur XFEM:
  La structure de la matrice n'est reconnue par le pré-conditionneur
  XFEM.
  Par précaution, on ne modifie pas le problème de départ.
  La résolution se poursuit sans pré-conditionneur XFEM.
"""),

    3 : _(u"""
  Erreur calcul matriciel:
  La matrice %(i1)d est pré-conditionnée sur les noeuds
  XFEM.
  Vous pourriez obtenir des résultats inattendus.
"""),

    4 : _(u"""
  Erreur lors d'un produit matrice-vecteur:
  La matrice %(i1)d est pré-conditionnée sur les noeuds
  XFEM.
  Vous pourriez obtenir des résultats inattendus.
"""),

    6 : _(u"""
  La mise à l'échelle des ddls X-FEM sera activée pour la suite de la résolution.
"""),

    7 : _(u"""
  Le pré-conditionneur XFEM a détecté une ligne pratiquement nulle à l'équation %(i1)d
  correspondante au noeud N%(i2)d et au degré de liberté %(k1)s.
  Conseils:
    - S'il s'agit d'un degré de liberté de type contact : vérifier que le chargement contact est 
      bien appliqué à la résolution et que toutes les sous-facettes de contact sont présentes en
      activant MODI_MODELE_XFEM/DECOUPE_FACETTE='SOUS_ELEMENTS'
    - Sinon, désactiver le pré-conditionneur X-FEM dans le MODI_MODELE_XFEM/PRETRAITEMENTS='SANS'
      pour tenter de poursuivre le calcul. Cette opération est très risquée.
"""),

    8 : _(u"""
  -> La connectivité stockée lors de la découpe XFEM ne situe pas 
     dans les bornes autorisées.
     Cela risque de produire des sous-éléments distordus à cause de la 
     mauvaise localisation des points de découpe.
  """),

}
