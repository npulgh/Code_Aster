# coding=utf-8
# person_in_charge: jean-luc.flejou at edf.fr


# ======================================================================
# COPYRIGHT (C) 1991 - 2015  EDF R&D                  WWW.CODE-ASTER.ORG
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

from cataelem.Tools.base_objects import InputParameter, OutputParameter, Option, CondCalcul
import cataelem.Commons.physical_quantities as PHY
import cataelem.Commons.parameters as SP
import cataelem.Commons.attributes as AT




PCAORIE  = InputParameter(phys=PHY.CAORIE, container='CARA!.CARORIEN',
comment="""  PCAORIE : ORIENTATION LOCALE D'UN ELEMENT DE POUTRE OU DE TUYAU,
           ISSUE DE AFFE_CARA_ELEM MOT CLE ORIENTATION """)


PNBSP_I  = InputParameter(phys=PHY.NBSP_I, container='CARA!.CANBSP',
comment="""  PNBSP_I :  NOMBRE DE SOUS_POINTS """)


EFGE_ELGA = Option(
    para_in=(
        SP.PCACOQU,
        SP.PCAGEPO,
           PCAORIE,
        SP.PMATERC,
           PNBSP_I,
        SP.PSIEFR,
    ),
    para_out=(
        SP.PEFGEC,
        SP.PEFGER,
    ),
    condition=(
      CondCalcul('+', ((AT.PHENO,'ME'),(AT.BORD,'0'),(AT.EFGE,'OUI'),)),
    ),
    comment="""  EFGE_ELGA : CALCUL DES CONTRAINTES AUX POINTS DE GAUSS
                A PARTIR DE SIEF_ELGA """,
)
