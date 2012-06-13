      SUBROUTINE MMFONC(FEPX,FMIN,FMAX)
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      CHARACTER*8 FEPX
      REAL*8       FMIN,FMAX
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.
C
C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.
C
C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C     CHARACTER*32 JEXNUM,JEXNOM,JEXR8,JEXATR

      CHARACTER*8   K8BID
      INTEGER       RL, JFON, I, NF0
      REAL*8        VAL

      CALL JEMARQ()

      CALL JELIRA ( FEPX//'           .VALE','LONUTI',RL, K8BID )
      CALL JEVEUO ( FEPX//'           .VALE', 'L', JFON )

      FMAX = -1.0D100
      FMIN = 1.0D100
      RL = INT(RL/2.D0)
      NF0 = JFON-1 + RL

      DO 20, I = 1, RL
        VAL = ZR(NF0 + I)
        IF(VAL .GT. FMAX)  FMAX = VAL
        IF(VAL .LT. FMIN)  FMIN = VAL
  20  CONTINUE

      CALL JEDEMA()

      END
