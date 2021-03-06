# coding=utf-8


# ======================================================================
# COPYRIGHT (C) 1991 - 2016  EDF R&D                  WWW.CODE-ASTER.ORG
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




PCOMPOR  = InputParameter(phys=PHY.COMPOR,
comment="""  Informations for non-linear comportment """)

PCAORIE  = InputParameter(phys=PHY.CAORIE, container='CARA!.CARORIEN',
comment="""  PCAORIE : ORIENTATION LOCALE D'UN ELEMENT DE POUTRE OU DE TUYAU  """)


PCONTMR  = InputParameter(phys=PHY.SIEF_R)


PVARIMR  = InputParameter(phys=PHY.VARI_R)


PVARCPR  = InputParameter(phys=PHY.VARI_R,
comment=""" PVARCPR : VARIABLES DE COMMANDES  POUR T+ """)


RIGI_MECA_IMPLEX = Option(
    para_in=(
        SP.PCACOQU,
        SP.PCAGNBA,
        SP.PCAMASS,
           PCAORIE,
        SP.PCARCRI,
           PCOMPOR,
        SP.PMULCOM,
           PCONTMR,
        SP.PDEPLMR,
        SP.PDEPLPR,
        SP.PGEOMER,
        SP.PINSTMR,
        SP.PINSTPR,
        SP.PMATERC,
        SP.PVARCMR,
           PVARCPR,
        SP.PVARCRR,
        SP.PVARIMP,
           PVARIMR,
    ),
    para_out=(
        SP.PCONTXR,
        SP.PMATUNS,
        SP.PMATUUR,
    ),
    condition=(
      CondCalcul('+', ((AT.PHENO,'ME'),(AT.BORD,'0'),)),
    ),
)
