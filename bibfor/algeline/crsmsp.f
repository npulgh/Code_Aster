      SUBROUTINE CRSMSP(SOLVBZ,MATASZ,PCPIV )
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      CHARACTER*(*) SOLVBZ,MATASZ
      INTEGER       PCPIV
C-----------------------------------------------------------------------
C     CREATION D'UNE SD SOLVEUR MUMPS SIMPLE PRECISION UTILISEE COMME
C     PRECONDITIONNEUR
C     ATTENTION A LA COHERENCE AVEC CRSVL2 ET CRSVMU
C-----------------------------------------------------------------------
C IN  K*  SOLVBZ    : NOM DE LA SD SOLVEUR MUMPS BIDON
C IN  K*  MATASZ    : MATRICE DU SYSTEME
C IN  I   PCPIV     : VALEUR DE PCENT_PIVOT
C-----------------------------------------------------------------------
C-----------------------------------------------------------------------
C-----------------------------------------------------------------------
C----------------------------------------------------------------------
C     VARIABLES LOCALES
C----------------------------------------------------------------------
      INTEGER JSLVK,JSLVR,JSLVI,IBID,IRET
      CHARACTER*19 MATASS,SOLVBD
      CHARACTER*8  SYMK
      CHARACTER*3  SYME
C----------------------------------------------------------------------
      CALL JEMARQ()

      SOLVBD = SOLVBZ
      MATASS = MATASZ
      
      CALL JEEXIN(SOLVBD, IRET)
      IF (IRET.EQ.0) CALL DETRSD('SOLVEUR',SOLVBD)

C     LA MATRICE EST-ELLE NON SYMETRIQUE
      CALL DISMOI('F','TYPE_MATRICE',MATASS,'MATR_ASSE',IBID,SYMK,IRET)
      IF (SYMK.EQ.'SYMETRI') THEN
        SYME='OUI'
      ELSE IF (SYMK.EQ.'NON_SYM') THEN
        SYME='NON'
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF

      CALL WKVECT(SOLVBD//'.SLVK','V V K24',12,JSLVK)
      CALL WKVECT(SOLVBD//'.SLVR','V V R',   4,JSLVR)
      CALL WKVECT(SOLVBD//'.SLVI','V V I',   7,JSLVI)

C     ATTENTION A LA COHERENCE AVEC CRSVL2 ET CRSVMU
      ZK24(JSLVK-1+1)  = 'MUMPS'
C     PRETRAITEMENTS
      ZK24(JSLVK-1+2)  = 'AUTO'
C     TYPE_RESOL
      IF (SYME .EQ.'NON') THEN
        ZK24(JSLVK-1+3)  = 'NONSYM'
      ELSE
        ZK24(JSLVK-1+3)  = 'SYMGEN'
      ENDIF
C     RENUM
      ZK24(JSLVK-1+4)  = 'AUTO'
C     SYME
      ZK24(JSLVK-1+5)  =  SYME
C     ELIM_LAGR2
      ZK24(JSLVK-1+6)  = 'NON'
C     MIXER_PRECISION
      ZK24(JSLVK-1+7)  = 'OUI'
C     PRECONDITIONNEUR
      ZK24(JSLVK-1+8)  = 'OUI'
C     OUT_OF_CORE
      ZK24(JSLVK-1+9)  = 'NON'
C     MATR_DISTRIBUEE
      ZK24(JSLVK-1+10) = 'NON'
C     POSTTRAITEMENTS
      ZK24(JSLVK-1+11) = 'SANS'
      ZK24(JSLVK-1+12) = 'NON'

      ZR(JSLVR-1+1) = -1.D0
      ZR(JSLVR-1+2) = -1.D0
      ZR(JSLVR-1+3) = 0.D0
      ZR(JSLVR-1+4) = 0.D0

      ZI(JSLVI-1+1) = -1
      ZI(JSLVI-1+2) = PCPIV
      ZI(JSLVI-1+3) = 0
      ZI(JSLVI-1+4) = -9999
      ZI(JSLVI-1+5) = -9999
      ZI(JSLVI-1+6) = -9999
      ZI(JSLVI-1+7) = -9999

      CALL JEDEMA()
      END
