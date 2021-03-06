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
# person_in_charge: mathieu.courtois at edf.fr


from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


LIRE_TABLE=MACRO(nom="LIRE_TABLE",
                 op=OPS('Macro.lire_table_ops.lire_table_ops'),
                 sd_prod=table_sdaster,
                 fr=tr("Lecture d'un fichier contenant une table"),
         UNITE           = SIMP(statut='o', typ=UnitType(), inout='in'),
         FORMAT          = SIMP(statut='f', typ='TXM', into=("ASTER", "LIBRE", "TABLEAU"), defaut="TABLEAU"),
         NUME_TABLE      = SIMP(statut='f', typ='I', defaut=1),
         SEPARATEUR      = SIMP(statut='f', typ='TXM', defaut=' '),
         RENOMME_PARA    = SIMP(statut='f', typ='TXM', into=("UNIQUE",),),
         TITRE           = SIMP(statut='f', typ='TXM',),
         INFO            = SIMP(statut='f', typ='I', into=(1, 2), ),
         )  ;
