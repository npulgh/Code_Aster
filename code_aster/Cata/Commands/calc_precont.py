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
# person_in_charge: sylvie.michel-ponnelle at edf.fr


from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


CALC_PRECONT=MACRO(nom="CALC_PRECONT",
                   op=OPS('Macro.calc_precont_ops.calc_precont_ops'),
                   sd_prod=evol_noli,
                   fr=tr("Imposer la tension définie par le BPEL dans les cables"),
                   reentrant='f',
         reuse =SIMP(statut='c',typ=CO),
         MODELE           =SIMP(statut='o',typ=modele_sdaster),
         CHAM_MATER       =SIMP(statut='o',typ=cham_mater),
         CARA_ELEM        =SIMP(statut='o',typ=cara_elem),
         CABLE_BP         =SIMP(statut='o',typ=cabl_precont,validators=NoRepeat(),max='**'),
         CABLE_BP_INACTIF =SIMP(statut='f',typ=cabl_precont,validators=NoRepeat(),max='**'),
         INCREMENT        =C_INCREMENT('MECANIQUE'),
         RECH_LINEAIRE    =C_RECH_LINEAIRE(),
         CONVERGENCE      =C_CONVERGENCE(),
#-------------------------------------------------------------------
         ETAT_INIT       =C_ETAT_INIT('STAT_NON_LINE','f'),
#-------------------------------------------------------------------
         METHODE = SIMP(statut='f',typ='TXM',defaut="NEWTON",into=("NEWTON","IMPLEX")),
         b_meth_newton = BLOC(condition = """equal_to("METHODE", 'NEWTON')""",
                           NEWTON = C_NEWTON(),
                        ),
         ENERGIE         =FACT(statut='f',max=1,
           CALCUL          =SIMP(statut='f',typ='TXM',into=("OUI",),defaut="OUI",),
         ),
#-------------------------------------------------------------------
#        Catalogue commun SOLVEUR
         SOLVEUR         =C_SOLVEUR('CALC_PRECONT'),
#-------------------------------------------------------------------
         INFO            =SIMP(statut='f',typ='I',into=(1,2) ),
         TITRE           =SIMP(statut='f',typ='TXM' ),

         EXCIT           =FACT(statut='o',max='**',
           CHARGE          =SIMP(statut='o',typ=char_meca),
           TYPE_CHARGE     =SIMP(statut='f',typ='TXM',defaut="FIXE_CSTE",
                                 into=("FIXE_CSTE","DIDI"))
         ),

         COMPORTEMENT       =C_COMPORTEMENT(),
  )  ;
