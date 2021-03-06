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


def asse_matrice_prod(MATR_ELEM,**args):
  if AsType(MATR_ELEM) == matr_elem_depl_r : return matr_asse_depl_r
  if AsType(MATR_ELEM) == matr_elem_depl_c : return matr_asse_depl_c
  if AsType(MATR_ELEM) == matr_elem_temp_r : return matr_asse_temp_r
  if AsType(MATR_ELEM) == matr_elem_pres_c : return matr_asse_pres_c
  raise AsException("type de concept resultat non prevu")

ASSE_MATRICE=OPER(nom="ASSE_MATRICE",op=12,sd_prod=asse_matrice_prod,
                  fr=tr("Construction d'une matrice assemblée"),reentrant='n',
         MATR_ELEM       =SIMP(statut='o',
                               typ=(matr_elem_depl_r,matr_elem_depl_c,matr_elem_temp_r,matr_elem_pres_c) ),
         NUME_DDL        =SIMP(statut='o',typ=nume_ddl_sdaster),
         SYME            =SIMP(statut='f',typ='TXM',into=("OUI",) ),
         CHAR_CINE       =SIMP(statut='f',typ=(char_cine_meca,char_cine_ther,char_cine_acou) ),
         INFO            =SIMP(statut='f',typ='I',into=(1,2) ),
)  ;
