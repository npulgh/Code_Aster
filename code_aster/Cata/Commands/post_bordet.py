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
# person_in_charge: david.haboussa at edf.fr

from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


POST_BORDET =MACRO(nom="POST_BORDET",
                   op=OPS('Macro.post_bordet_ops.post_bordet_ops'),
                   sd_prod=table_sdaster,
                   reentrant='n',
                   fr=tr("calcul de la probabilite de clivage via le modele de Bordet"),
         regles=(UN_PARMI('TOUT','GROUP_MA'),
                 UN_PARMI('INST','NUME_ORDRE'),
                 ),
         TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",)),
         GROUP_MA        =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**',
                           fr=tr("le calcul ne sera effectué que sur ces mailles")),
         INST            =SIMP(statut='f',typ='R',validators=NoRepeat(),),
         PRECISION =SIMP(statut='f',typ='R',validators=NoRepeat(),val_min=0.,val_max=1E-3,defaut=1E-6),
         CRITERE   =SIMP(statut='f',typ='TXM',defaut="ABSOLU",into=("RELATIF","ABSOLU") ),
         NUME_ORDRE      =SIMP(statut='f',typ='I',validators=NoRepeat(),),
         PROBA_NUCL      =SIMP(statut='f',typ='TXM',into=("NON","OUI"), defaut="NON",
                      fr=tr("prise en compte du facteur exponentiel")),
         b_nucl          =BLOC( condition = """equal_to("PROBA_NUCL", 'OUI')""",
                          PARAM =FACT(statut='o',
                                 M                =SIMP(statut='o',typ='R',val_min=0.E+0),
                                 SIGM_REFE         =SIMP(statut='o',typ=(fonction_sdaster),val_min=0.E+0),
                                 VOLU_REFE        =SIMP(statut='o',typ='R',val_min=0.E+0),
                                 SIG_CRIT         =SIMP(statut='o',typ='R',val_min=0.E+0),
                                 SEUIL_REFE       =SIMP(statut='o',typ='R',val_min=0.E+0),
                                 SEUIL_CALC       =SIMP(statut='o',typ=(fonction_sdaster,nappe_sdaster)),
                                 DEF_PLAS_REFE    =SIMP(statut='o',typ='R'),),),

         b_prop          =BLOC( condition = """equal_to("PROBA_NUCL", 'NON')""",
                          PARAM =FACT(statut='o',
                                 M                =SIMP(statut='o',typ='R',val_min=0.E+0),
                                 SIGM_REFE         =SIMP(statut='o',typ=fonction_sdaster,val_min=0.E+0),
                                 VOLU_REFE        =SIMP(statut='o',typ='R',val_min=0.E+0),
                                 SIG_CRIT         =SIMP(statut='o',typ='R',val_min=0.E+0),
                                 SEUIL_REFE       =SIMP(statut='o',typ='R',val_min=0.E+0),
                                 SEUIL_CALC       =SIMP(statut='o',typ=(fonction_sdaster,nappe_sdaster),),
                                 ),
                                 ),

         RESULTAT        =SIMP(statut='o',typ=resultat_sdaster,
                                      fr=tr("Resultat d'une commande globale STAT_NON_LINE")),
         TEMP            =SIMP(statut='o',typ=(fonction_sdaster,'R')),
         COEF_MULT       =SIMP(statut='f',typ='R', defaut=1.),
           )
