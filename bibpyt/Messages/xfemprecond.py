# coding=utf-8
# ======================================================================
# COPYRIGHT (C) 1991 - 2013  EDF R&D                  WWW.CODE-ASTER.ORG
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
  La matrice n'est pas symétrique ou à une structure 
  non symétrique. Le calcul du pré-conditionneur 
  XFEM <<NODAL>> ne supporte pas encore ce type de
  matrices.
  Par précaution, on ne modifie pas le problème de départ. 
  La résolution se poursuit sans pré-conditionneur XFEM.
"""),

2 : _(u"""
  Erreur de programmation :
  On essaie d'activer le préconditionneur <<NODAL>> 
  alors que l'ordonnancement des numéros d'équation stockées dans le
  NUME_DDL associé à la  matrice en cours de factorisation 
  ne correspond pas l'application identité.   
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

5 : _(u"""
  Alarme émise par le pré-conditionneur XFEM:
  Le calcul d'une matrice locale de pré-conditionnement a
  échoué.
  Par précaution, on ne modifie pas le problème de départ.
  La résolution se poursuit sans le pré-conditionneur XFEM.
"""),

6 : _(u"""
  Le pré-conditionneur XFEM <<NODAL>> sera activé pour la 
  suite de la résolution. 
"""),

7 : _(u"""
  La matrice pré-conditionnée XFEM va être détruite. 
  La matrice initiale va être reconstruite par produit
  avec l'inverse du pré-conditionneur XFEM.   
"""),

}