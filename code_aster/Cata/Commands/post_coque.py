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
# person_in_charge: ayaovi-dzifa.kudawoo at edf.fr

from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


POST_COQUE=MACRO(nom="POST_COQUE",
                 op=OPS('Macro.post_coque_ops.post_coque_ops'),
                 sd_prod=table_sdaster,
                 reentrant='n',
                 fr=tr("Calcul des efforts et déformations en un point et une cote "
                      "quelconque de la coque"),

             regles=(EXCLUS('INST','NUME_ORDRE'),),

             # SD résultat et champ à posttraiter :
             RESULTAT        =SIMP(statut='o',typ=resultat_sdaster,fr=tr("RESULTAT à posttraiter"),),
             CHAM            =SIMP(statut='o',typ='TXM',into=("EFFORT","DEFORMATION",)),
             NUME_ORDRE      =SIMP(statut='f',typ='I'),
             INST            =SIMP(statut='f',typ='R'),

             # points de post-traitement :
             COOR_POINT      =FACT(statut='o',max='**',fr=tr("coordonnées et position dans l'épaisseur"),
                                   COOR=SIMP(statut='o',typ='R',min=3,max=4),),

            )
