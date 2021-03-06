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
# person_in_charge: natacha.bereux at edf.fr

from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


RESOUDRE=OPER(nom="RESOUDRE",op=15,sd_prod=cham_no_sdaster,reentrant='f',
               fr=tr("Résolution par méthode directe un système d'équations linéaires préalablement factorisé par FACT_LDLT"
                  "ou Résolution d'un système linéaire par la méthode du gradient conjugué préconditionné"),
         reuse=SIMP(statut='c', typ=CO),
         MATR           =SIMP(statut='o',typ=(matr_asse_depl_r,matr_asse_depl_c,matr_asse_temp_r,
                                               matr_asse_temp_c,matr_asse_pres_r,matr_asse_pres_c) ),
         CHAM_NO         =SIMP(statut='o',typ=cham_no_sdaster),
         CHAM_CINE       =SIMP(statut='f',typ=cham_no_sdaster),

         # mot-clé commun aux solveurs MUMPS, GCPC et PETSc:
         RESI_RELA       =SIMP(statut='f',typ='R',defaut=1.E-6),

         # mot-clé pour les posttraitements de la phase de solve de MUMPS
         POSTTRAITEMENTS =SIMP(statut='f',typ='TXM',defaut="AUTO",into=("SANS","AUTO","FORCE","MINI")),

         # mot-clé commun aux solveurs GCPC et PETSc:
         NMAX_ITER       =SIMP(statut='f',typ='I',defaut= 0 ),
         MATR_PREC       =SIMP(statut='f',typ=(matr_asse_depl_r,matr_asse_temp_r,matr_asse_pres_r ) ),

         # mots-clés pour solveur PETSc:
         ALGORITHME      =SIMP(statut='f',typ='TXM',into=("CG", "CR", "GMRES", "GCR", "FGMRES" ),defaut="FGMRES" ),

         TITRE           =SIMP(statut='f',typ='TXM'),
         INFO            =SIMP(statut='f',typ='I',into=(1,2) ),
)  ;
