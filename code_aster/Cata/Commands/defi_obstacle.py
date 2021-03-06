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
# person_in_charge: marc.kham at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


DEFI_OBSTACLE=OPER(nom="DEFI_OBSTACLE",op=  73,sd_prod=table_fonction,
                   fr=tr("Définition d'un obstacle plan perpendiculaire à une structure filaire"),
                   reentrant='n',
         TYPE            =SIMP(statut='o',typ='TXM',defaut="CERCLE",
                             into=("CERCLE","PLAN_Y","PLAN_Z","DISCRET",
                             "BI_CERCLE","BI_PLAN_Y","BI_PLAN_Z","BI_CERC_INT",
                             ) ),
         VALE            =SIMP(statut='f',typ='R',max='**'),
         VERIF           =SIMP(statut='f',typ='TXM',defaut="FERME"),
)  ;
