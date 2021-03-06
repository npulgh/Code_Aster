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
# Le calcul de la pression sur une interface est utilie en mécanique notamment
# en mécanique de contact, mécanique de la rupture,....
# Cette routine produit un cham_gd calculé à partir du tenseur de contraintes nodale SIEF_NOEU
# L'option n'existe que pour les éléments isoparamétriques mais elle pourra être étendue
# au frottement et aux éléments de structures si le besoin se manifeste.


from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


CALC_PRESSION=MACRO(nom="CALC_PRESSION",
                    op=OPS('Macro.calc_pression_ops.calc_pression_ops'),
                    sd_prod=cham_no_sdaster,
                    fr="Calcul de la pression nodale sur une interface a partir de SIEF_NOEU. Cette option n existe que pour les éléments isoparamétriques.",

         MAILLAGE        =SIMP(statut='o',typ=maillage_sdaster),
         RESULTAT        =SIMP(statut='o',typ=(evol_elas,evol_noli)),
         GROUP_MA        =SIMP(statut='o',typ=grma ,validators=NoRepeat(),max='**'),
         INST            =SIMP(statut='o',typ='R',max='**'),
         MODELE          =SIMP(statut='f',typ=modele_sdaster),
         GEOMETRIE      = SIMP(statut='o',typ='TXM',defaut="INITIALE",into=("INITIALE","DEFORMEE")),
         INFO            =SIMP(statut='f',typ='I',defaut=1,into=(1,2)),
);
