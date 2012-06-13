      SUBROUTINE NMETNC(SDIETO,ICHAM ,NOMCHA)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT      NONE
      INCLUDE 'jeveux.h'
      CHARACTER*24  SDIETO
      CHARACTER*(*) NOMCHA
      INTEGER       ICHAM
C
C ----------------------------------------------------------------------
C
C ROUTINE GESTION IN ET OUT
C
C RETOURNE LE NOM DU CHAMP DANS L'OPERATEUR
C
C ----------------------------------------------------------------------
C
C
C IN  SDIETO : SD GESTION IN ET OUT
C IN  ICHAM  : INDEX DU CHAMP DANS SDIETO
C OUT NOMCHA : NOM DU CHAMP DANS L'OPERATEUR
C
C
C
C
      CHARACTER*24 IOINFO,IOLCHA
      INTEGER      JIOINF,JIOLCH
      INTEGER      ZIOCH
      CHARACTER*24 NOMCHX
      CHARACTER*6  TYCHAP,TYVARI
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- ACCES SD IN ET OUT
C
      IOINFO = SDIETO(1:19)//'.INFO'
      IOLCHA = SDIETO(1:19)//'.LCHA'
      CALL JEVEUO(IOINFO,'L',JIOINF)
      CALL JEVEUO(IOLCHA,'L',JIOLCH)
      ZIOCH  = ZI(JIOINF+4-1)
C
C --- NOM DU CHAMP DANS L'OPERATEUR
C
      NOMCHX = ZK24(JIOLCH+ZIOCH*(ICHAM-1)+6-1)
C
C --- NOM DU CHAMP A STOCKER
C
      IF (NOMCHX(1:5).EQ.'CHAP#') THEN
        TYCHAP = NOMCHX(6:11)
        IF (TYCHAP.EQ.'VALINC') THEN
          TYVARI = NOMCHX(13:18)
          IF (TYVARI.EQ.'TEMP') THEN
            NOMCHA = '&&NXLECTVAR_____'
          ELSE
            NOMCHA = '&&OP0070.'//TYVARI
          ENDIF
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
      ELSE
        NOMCHA = NOMCHX
      ENDIF
C
      CALL JEDEMA()
      END
