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
# person_in_charge: isabelle.fournier at edf.fr


from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


STANLEY=MACRO(nom="STANLEY",
              op=OPS('Macro.stanley_ops.stanley_ops'),
              sd_prod=None,
              reentrant='n',
              fr=tr("Outil de post-traitement interactif Stanley "),
         RESULTAT        =SIMP(statut='f',typ=(evol_elas,evol_noli,evol_ther,mode_meca,dyna_harmo,dyna_trans) ),
         MODELE          =SIMP(statut='f',typ=modele_sdaster),
         CHAM_MATER      =SIMP(statut='f',typ=cham_mater),
         CARA_ELEM       =SIMP(statut='f',typ=cara_elem),
         DISPLAY         =SIMP(statut='f',typ='TXM'),
         UNITE_VALIDATION=SIMP(statut='f',typ=UnitType(),val_min=10,val_max=90, inout='out',
                               fr=tr("Unité logique définissant le fichier (fort.N) dans lequel on écrit les md5")),

)  ;
