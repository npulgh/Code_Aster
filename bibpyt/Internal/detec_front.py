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
# person_in_charge: samuel.geniaut at edf.fr

from code_aster.Cata.Syntax import OPER, SIMP
from code_aster.Cata.DataStructure import table_sdaster, evol_noli, fiss_xfem


DETEC_FRONT = OPER(
    nom="DETEC_FRONT", op=139, sd_prod=table_sdaster, reentrant='n',
    fr="Detection de front cohesif avec X-FEM",

    FISSURE=SIMP(statut='o', typ=fiss_xfem),
    NB_POINT_FOND=SIMP(statut='f', typ='I', val_min=2),
    RESULTAT=SIMP(statut='o', typ=evol_noli),

)
