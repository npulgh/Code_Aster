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
# person_in_charge: mathieu.corus at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


def asse_matr_gene_prod(METHODE,**args):
    if   (METHODE=="INITIAL") : return matr_asse_gene_r
    elif (args['OPTION']=="RIGI_GENE_C") : return matr_asse_gene_c
    else : return matr_asse_gene_r

ASSE_MATR_GENE=OPER(nom="ASSE_MATR_GENE",op= 128,sd_prod=asse_matr_gene_prod,
                    fr=tr("Assemblage des matrices généralisées de macro éléments pour construction de la matrice globale généralisée"),
                    reentrant='n',
         NUME_DDL_GENE   =SIMP(statut='o',typ=nume_ddl_gene ),
         METHODE          =SIMP(statut='f',typ='TXM',defaut="CLASSIQUE",into=("CLASSIQUE","INITIAL") ),
         b_option     =BLOC(condition = """equal_to("METHODE", 'CLASSIQUE')""",
           OPTION          =SIMP(statut='o',typ='TXM',into=("RIGI_GENE","RIGI_GENE_C","MASS_GENE","AMOR_GENE") ),
           ),
)  ;
