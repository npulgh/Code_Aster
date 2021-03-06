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


CALC_CHAR_CINE=OPER(nom="CALC_CHAR_CINE",op= 102,sd_prod=cham_no_sdaster,
                    fr=tr("Calcul des seconds membres associés à des charges cinématiques (conditions aux limites non dualisées)"),
                    reentrant='n',
         NUME_DDL        =SIMP(statut='o',typ=nume_ddl_sdaster ),
         CHAR_CINE       =SIMP(statut='o',typ=(char_cine_meca,char_cine_ther,char_cine_acou ),validators=NoRepeat(),max='**' ),
         INST            =SIMP(statut='f',typ='R',defaut= 0.E+0 ),
         INFO            =SIMP(statut='f',typ='I',defaut= 1,into=( 1 , 2 ) ),
)  ;
