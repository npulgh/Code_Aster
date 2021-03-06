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
# person_in_charge: j-pierre.lefebvre at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


DETRUIRE=MACRO(nom="DETRUIRE",
               op=OPS("code_aster.Cata.ops.DETRUIRE"),
               fr=tr("Détruit des concepts utilisateurs dans la base GLOBALE ou des objets JEVEUX"),
               op_init=ops.build_detruire,
    regles=(UN_PARMI('CONCEPT', 'OBJET',),),

    CONCEPT = FACT(statut='f',max='**',
        NOM         = SIMP(statut='o',typ=assd,validators=NoRepeat(),max='**'),
    ),
    OBJET = FACT(statut='f',max='**',
       CLASSE   = SIMP(statut='f', typ='TXM', into=('G', 'V', 'L'), defaut='G'),
       CHAINE   = SIMP(statut='o', typ='TXM', validators=NoRepeat(), max='**'),
       POSITION = SIMP(statut='f', typ='I', max='**'),
    ),
    INFO   = SIMP(statut='f', typ='I', into=(1, 2), defaut=1, ),
)
