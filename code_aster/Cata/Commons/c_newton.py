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
# person_in_charge: mickael.abbas at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *


def C_NEWTON() : return FACT(statut='d',
           REAC_INCR       =SIMP(statut='f',typ='I',defaut= 1,val_min=0),
           PREDICTION      =SIMP(statut='f',typ='TXM',into=("DEPL_CALCULE","TANGENTE","ELASTIQUE","EXTRAPOLE") ),
           MATRICE         =SIMP(statut='f',typ='TXM',defaut="TANGENTE",into=("TANGENTE","ELASTIQUE") ),
           PAS_MINI_ELAS   =SIMP(statut='f',typ='R',val_min=0.0),
           REAC_ITER       =SIMP(statut='f',typ='I',defaut=1,val_min=0),
           REAC_ITER_ELAS  =SIMP(statut='f',typ='I',defaut=0,val_min=0),
           EVOL_NOLI       =SIMP(statut='f',typ=evol_noli),
           MATR_RIGI_SYME  =SIMP(statut='f', typ='TXM', defaut="NON", into=("OUI", "NON", ), ),
         );
