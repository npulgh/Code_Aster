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
# person_in_charge: sofiane.hendili at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


DEFI_TRC=OPER(nom="DEFI_TRC",op=94,sd_prod=table_sdaster,reentrant='n',
              fr=tr("Définir d'un diagramme de transformations en refroidissement continu (TRC) de référence d'un acier"
                " pour les calculs métallurgiques."),
         HIST_EXP        =FACT(statut='o',max='**',
           VALE            =SIMP(statut='o',typ='R',max='**'),
         ),
         TEMP_MS         =FACT(statut='o',max='**',
           SEUIL           =SIMP(statut='o',typ='R'),
           AKM             =SIMP(statut='o',typ='R'),
           BKM             =SIMP(statut='o',typ='R'),
           TPLM            =SIMP(statut='o',typ='R'),
         ),
         GRAIN_AUST      =FACT(statut='f',max='**',
           DREF           =SIMP(statut='f',typ='R'),
           A              =SIMP(statut='f',typ='R'),
         ),
)  ;
