# -*- coding: utf-8 -*-
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
# person_in_charge: nicolas.greffet at edf.fr
#
#  RECUPERATION DES EFFORTS VIA YACS POUR COUPLAGE IFS
#

from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


MODI_CHAR_YACS=OPER(nom            = "MODI_CHAR_YACS",
                   op              = 112,
                   sd_prod         = char_meca,
                   reentrant       = 'o',
                   fr              = tr("Reception des forces nodales via YACS lors du couplage de  Code_Aster et Saturne"),
                   CHAR_MECA       = SIMP(statut ='o', typ = char_meca),
                   MATR_PROJECTION = SIMP(statut ='o', typ = corresp_2_mailla,),
                   NOM_CMP_IFS     = SIMP(statut ='o', typ = 'TXM',validators = NoRepeat(), max = '**'),
                   VIS_A_VIS       = FACT(statut ='o', max = '**',
                                   GROUP_MA_1 = SIMP(statut='o',typ=grma,validators=NoRepeat(),max='**'),
                                   GROUP_NO_2 = SIMP(statut='o',typ=grno,validators=NoRepeat(),max='**'),),
                   INST            = SIMP(statut='o',typ='R', ),
                   PAS             = SIMP(statut='o',typ='R', ),
                   NUME_ORDRE_YACS = SIMP(statut='o', typ='I',),
                   INFO            = SIMP(statut='f',typ='I',defaut=1,into=(1,2) ),
);
