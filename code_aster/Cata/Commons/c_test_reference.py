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


def C_TEST_REFERENCE(keyword, max=1):       #COMMUN#
    """Mots-clés communs pour TEST_RESU, TEST_TABLE, TEST_FONCTION.
    On retourne un bloc pour ajouter la règle UN_PARMI."""
    assert keyword in ('CHAM_NO', 'CHAM_ELEM', 'CARTE', 'RESU', 'GENE', 'OBJET',
                       'TABLE', 'FONCTION', 'FICHIER', 'MAILLAGE')
    with_int     = keyword not in ('FONCTION', )
    with_complex = keyword not in ('OBJET', 'FICHIER', 'MAILLAGE')
    with_string  = keyword in ('FICHIER', 'TABLE')
    vale_abs     = keyword not in ('CARTE', 'FICHIER')
    type_test    = keyword not in ('CARTE', 'GENE', 'OBJET')
    multi_prec   = keyword in ('RESU', 'GENE')
    reference    = keyword not in ('FICHIER', )
    un_parmi     = keyword not in ('FICHIER', )

    opts = {}
    opts_ref = {}
    types = ['',]
    def add_type(typ):
        ttyp = typ == 'K' and 'TXM' or typ
        types.append('_' + typ)
        opts['VALE_CALC_' + typ] = SIMP(statut='f',typ=ttyp,max=max)
        opts_ref['VALE_REFE_' + typ] = SIMP(statut='f',typ=ttyp,max=max)
    if with_int:
        add_type('I')
    if with_complex:
        add_type('C')
    if with_string:
        add_type('K')
    if vale_abs:
        opts['VALE_ABS'] = SIMP(statut='f',typ='TXM',defaut="NON",into=("OUI","NON"))
    if type_test:
        opts['TYPE_TEST'] = SIMP(statut='f',typ='TXM',into=("SOMM_ABS","SOMM","MAX","MIN"))
    if not multi_prec:
        opts['TOLE_MACHINE'] = SIMP(statut='f',typ='R',defaut=1.e-6)
        opts['CRITERE']      = SIMP(statut='f',typ='TXM',defaut='RELATIF',into=("RELATIF","ABSOLU"))
    else:
        opts['TOLE_MACHINE'] = SIMP(statut='f',typ='R',max=2)
        opts['CRITERE']      = SIMP(statut='f',typ='TXM',max=2,into=("RELATIF","ABSOLU"))
    if un_parmi:
        opts['regles'] = (UN_PARMI(*['VALE_CALC' + t for t in types]))
        opts_ref['regles'] = (UN_PARMI(*['VALE_REFE' + t for t in types]))
    if reference:
        opts['b_reference'] = BLOC(condition = """exists("REFERENCE")""",
            VALE_REFE   = SIMP(statut='f',typ='R',max=max),
            PRECISION   = SIMP(statut='f',typ='R',defaut=1.e-3),
            **opts_ref)
        opts['REFERENCE'] = SIMP(statut='f',typ='TXM',
                                 into=("ANALYTIQUE","SOURCE_EXTERNE","AUTRE_ASTER","NON_DEFINI"))
    kwargs = {
        'b_values' : BLOC(condition = """True""",
            VALE_CALC    = SIMP(statut='f',typ='R',max=max),
            # tricky because VALE_CALC may be a tuple or a scalar
            b_ordre_grandeur = BLOC(condition="""exists("VALE_CALC") and abs(VALE_CALC if type(VALE_CALC) not in (list, tuple) else VALE_CALC[0]) < 1.e-16""",
                ORDRE_GRANDEUR = SIMP(statut='f',typ='R'),
            ),
            LEGENDE      = SIMP(statut='f',typ='TXM'),
            **opts
        )
    }
    return kwargs
