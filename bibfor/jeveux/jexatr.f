      CHARACTER*32 FUNCTION   JEXATR ( NOMC , NOMA )
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF JEVEUX  DATE 13/11/2012   AUTEUR COURTOIS M.COURTOIS 
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
C RESPONSABLE LEFEBVRE J-P.LEFEBVRE
      IMPLICIT NONE
      INCLUDE 'jeveux_private.h'
      CHARACTER*(*)       NOMC , NOMA
C ----------------------------------------------------------------------
      INTEGER          LK1ZON , JK1ZON , LISZON , JISZON 
      COMMON /IZONJE/  LK1ZON , JK1ZON , LISZON , JISZON
      INTEGER          ICLAS ,ICLAOS , ICLACO , IDATOS , IDATCO , IDATOC
      COMMON /IATCJE/  ICLAS ,ICLAOS , ICLACO , IDATOS , IDATCO , IDATOC
C     ------------------------------------------------------------------
      INTEGER          NUMATR
      COMMON /IDATJE/  NUMATR
C     ------------------------------------------------------------------
      INTEGER        IDIADD          ,
     &                             IDLONG     ,
     &               IDLONO     , IDLUTI     
C-----------------------------------------------------------------------
      INTEGER IBACOL ,IXIADD ,IXLONG ,IXLONO ,IXLUTI 
C-----------------------------------------------------------------------
      PARAMETER    ( IDIADD = 2  ,
     &                             IDLONG = 7 ,
     &               IDLONO = 8 , IDLUTI = 9  )
C     ------------------------------------------------------------------
      INTEGER          ICRE , IRET
      CHARACTER*24     NOM24
      CHARACTER*6      NOMALU
      CHARACTER*8      CH8
      DATA             CH8      / '$$XATR  ' /
C DEB ------------------------------------------------------------------
C
      NOM24  = NOMC
      NOMALU = NOMA
      IF ( NOMALU .NE. 'LONCUM' .AND. NOMALU .NE. 'LONMAX'
     &                          .AND. NOMALU .NE. 'LONUTI') THEN
        CALL U2MESK('F','JEVEUX1_28',1,NOMALU)
      ENDIF
      ICRE = 0
      CALL JJVERN ( NOM24//'        ' , ICRE ,IRET )
      IF ( IRET .NE. 2 ) THEN
        CALL U2MESS('F','JEVEUX1_29')
      ELSE
        CALL JJALLC ( ICLACO , IDATCO , 'L' , IBACOL )
        IF ( NOMALU .EQ. 'LONCUM') THEN
          IXIADD = ISZON ( JISZON + IBACOL + IDIADD )
          IF ( IXIADD .NE. 0 ) THEN
            CALL U2MESS('F','JEVEUX1_30')
          ENDIF
          IXLONO = ISZON ( JISZON + IBACOL + IDLONO )
          IF ( IXLONO .EQ. 0 ) THEN
            CALL U2MESK('F','JEVEUX1_63',1,'LONCUM')
          ENDIF
          JEXATR = NOM24//CH8
          NUMATR = IXLONO
        ELSE IF ( NOMALU .EQ. 'LONMAX') THEN
          IXLONG = ISZON ( JISZON + IBACOL + IDLONG )
          IF ( IXLONG .EQ. 0 ) THEN
            CALL U2MESK('F','JEVEUX1_63',1,'LONMAX')
          ENDIF
          JEXATR = NOM24//CH8
          NUMATR = IXLONG
        ELSE IF ( NOMALU .EQ. 'LONUTI') THEN
          IXLUTI = ISZON ( JISZON + IBACOL + IDLUTI )
          IF ( IXLUTI .EQ. 0 ) THEN
            CALL U2MESK('F','JEVEUX1_63',1,'LONUTI')
          ENDIF
          JEXATR = NOM24//CH8
          NUMATR = IXLUTI
        ENDIF
      ENDIF
C DEB ------------------------------------------------------------------
      END
