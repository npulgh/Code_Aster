      SUBROUTINE CALCFO ( COMPL, NOMFIN, NOMFON, NBVAL, VALE, NOPARA )
      IMPLICIT   NONE
      INCLUDE 'jeveux.h'
      INTEGER             NBVAL
      REAL*8              VALE(*)
      LOGICAL             COMPL
      CHARACTER*24        NOPARA
      CHARACTER*19        NOMFIN, NOMFON
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
C
C     CREATION DU SD FONCTION A PARTIR D'UNE FORMULE (FONCTION )
C     ------------------------------------------------------------------
      INTEGER      IER, NBVAL2, LVALE, LFON, IVAL, LPROL, LXLGUT
C     ------------------------------------------------------------------
C
      CALL JEMARQ()
C
C     --- CREATION ET REMPLISSAGE DE L'OBJET NOMFON.VALE ---
C
      IF ( COMPL ) THEN
         NBVAL2 = 3*NBVAL
      ELSE
         NBVAL2 = 2*NBVAL
      ENDIF
C
      CALL WKVECT ( NOMFON//'.VALE', 'G V R', NBVAL2, LVALE )
      LFON = LVALE + NBVAL
      DO 10 IVAL = 0, NBVAL-1
         ZR(LVALE+IVAL) = VALE(IVAL+1)
         IF ( COMPL ) THEN
            CALL FOINTC( 'F', NOMFIN, 1, NOPARA, ZR(LVALE+IVAL),
     &                   ZR(LFON+2*IVAL), ZR(LFON+2*IVAL+1), IER )
         ELSE
            CALL FOINTE ( 'F', NOMFIN, 1, NOPARA,
     &                          ZR(LVALE+IVAL), ZR(LFON+IVAL), IER )
         ENDIF
 10   CONTINUE
C
C     --- CREATION ET REMPLISSAGE DE L'OBJET NOMFON.PROL ---
C
      CALL ASSERT(LXLGUT(NOMFON).LE.24)
      CALL WKVECT ( NOMFON//'.PROL', 'G V K24', 6, LPROL )
      IF ( COMPL ) THEN
         ZK24(LPROL)   = 'FONCT_C         '
      ELSE
         ZK24(LPROL)   = 'FONCTION        '
      ENDIF
      ZK24(LPROL+1) = 'LIN LIN         '
      ZK24(LPROL+2) = NOPARA
      ZK24(LPROL+3) = 'TOUTRESU        '
      ZK24(LPROL+4) = 'EE              '
      ZK24(LPROL+5) = NOMFON
C
      CALL JEDEMA()
      END
