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
# person_in_charge: jacques.pellet at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


ENGENDRE_TEST=PROC(nom="ENGENDRE_TEST",op=178,
                   fr=tr("Engendre des tests pour la non régression du code (pour développeurs)"),
         UNITE           =SIMP(statut='f',typ=UnitType(),defaut=8, inout='out'),
         FORMAT          =SIMP(statut='f',typ='TXM',into=("ASTER", "OBJET"), defaut="ASTER" ),
         FORMAT_R        =SIMP(statut='f',typ='TXM',defaut="1PE20.13"),
         PREC_R          =SIMP(statut='f',typ='TXM',defaut="1.E-10"),
#============================================================================
         b_aster     =BLOC( condition = """equal_to("FORMAT", 'ASTER')""",
            CO              =SIMP(statut='o',typ=(cham_gd_sdaster,resultat_sdaster,table_sdaster),
                                  validators=NoRepeat(),max='**'),
            TYPE_TEST       =SIMP(statut='f',typ='TXM',defaut="SOMM_ABS",into=("SOMME","SOMM_ABS","MAX","MIN") ),
         ),
#============================================================================
         b_objet     =BLOC( condition = """equal_to("FORMAT", 'OBJET')""",
                            regles=(UN_PARMI('TOUT','CO'),),
            TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",) ),
            CO              =SIMP(statut='f',typ=assd,validators=NoRepeat(),max='**'),
            TYPE_TEST       =SIMP(statut='f',typ='TXM',defaut="SOMME",into=("SOMME",) ),
         ),
)  ;
