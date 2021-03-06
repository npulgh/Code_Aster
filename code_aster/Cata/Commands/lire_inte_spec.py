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
# person_in_charge: irmela.zentner at edf.fr


from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


LIRE_INTE_SPEC=MACRO(nom="LIRE_INTE_SPEC",
                     op=OPS('Macro.lire_inte_spec_ops.lire_inte_spec_ops'),
                     sd_prod=interspectre,
                     fr=tr("Lecture sur un fichier externe de fonctions complexes pour "
                          "créer une matrice interspectrale"),
                     reentrant='n',
         UNITE           =SIMP(statut='o',typ=UnitType(), inout='in'),
         FORMAT_C        =SIMP(statut='f',typ='TXM',defaut="MODULE_PHASE",into=("REEL_IMAG","MODULE_PHASE") ),
         FORMAT          =SIMP(statut='f',typ='TXM',defaut="ASTER",into=("ASTER","IDEAS") ),
         NOM_PARA        =SIMP(statut='f',typ='TXM',defaut="FREQ",
                               into=("DX","DY","DZ","DRX","DRY","DRZ","TEMP",
                                     "INST","X","Y","Z","EPSI","FREQ","PULS","AMOR","ABSC",) ),
         NOM_RESU        =SIMP(statut='f',typ='TXM',defaut="DSP" ),
         INTERPOL        =SIMP(statut='f',typ='TXM',max=2,into=("NON","LIN","LOG") ),
         PROL_DROITE     =SIMP(statut='f',typ='TXM',into=("CONSTANT","LINEAIRE","EXCLU") ),
         PROL_GAUCHE     =SIMP(statut='f',typ='TXM',into=("CONSTANT","LINEAIRE","EXCLU") ),
         TITRE           =SIMP(statut='f',typ='TXM'),
         INFO            =SIMP(statut='f',typ='I',defaut= 1,into=( 1 , 2) ),
)  ;
