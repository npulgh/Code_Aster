      SUBROUTINE PALIM3 ( MCFACT, IOCC, NOMAZ, NOMVEI, NOMVEK, NBMST )
      IMPLICIT NONE
      INCLUDE 'jeveux.h'

      CHARACTER*32 JEXNOM
      INTEGER                     IOCC,                        NBMST
      CHARACTER*(*)       MCFACT,       NOMAZ, NOMVEI, NOMVEK
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 18/12/2012   AUTEUR SELLENET N.SELLENET 
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
C
C IN   NOMAZ  : NOM DU MAILLAGE
C OUT  NBMST  : NOMBRE DE MAILLES RECUPEREES
C     ------------------------------------------------------------------
C
      INTEGER       N1, IER, IM, NUMA, NUME, IBID, LGP, LGM,
     &              ILIST, KLIST, LXLGUT, NBV1, I, NBMC, NBMA, JNOMA
      PARAMETER     ( NBMC = 3 )
      LOGICAL       LNUME,LGRPMA
      CHARACTER*1   K1B
      CHARACTER*8   NOMA, PRFM, NOMMAI, KNUME, K8B
      CHARACTER*16  TYMOCL(NBMC), MOTCLE(NBMC)
      CHARACTER*24  NOMAMA, NOMJV, GRPMA
      CHARACTER*24  VALK(3)
      INTEGER      IARG
C     ------------------------------------------------------------------
C
      CALL JEMARQ ( )
C
      NOMA   = NOMAZ
      NOMAMA = NOMA//'.NOMMAI'
C
      CALL JEVEUO ( NOMVEI , 'E' , ILIST )
      CALL JEVEUO ( NOMVEK , 'E' , KLIST )
      CALL JELIRA ( NOMVEK , 'LONMAX', NBV1, K1B )
      IER = 0
C
      CALL GETVTX ( MCFACT, 'PREF_MAILLE', IOCC,IARG,1, PRFM, N1)
      LGP = LXLGUT(PRFM)
C
      LNUME = .FALSE.
      CALL GETVIS ( MCFACT, 'PREF_NUME', IOCC,IARG,0, IBID, N1)
      IF ( N1 .NE. 0 ) THEN
         LNUME = .TRUE.
         CALL GETVIS ( MCFACT, 'PREF_NUME', IOCC,IARG,1, NUME, N1 )
      ENDIF
C
      LGRPMA = .FALSE.
      CALL GETVTX ( MCFACT, 'GROUP_MA', IOCC,IARG,0, K8B, N1)
      IF ( N1 .NE. 0 ) THEN
         LGRPMA= .TRUE.
         CALL GETVTX ( MCFACT, 'GROUP_MA', IOCC,IARG,1, GRPMA, N1 )
      ENDIF
C
      MOTCLE(1) = 'TOUT'
      TYMOCL(1) = 'TOUT'
      MOTCLE(2) = 'GROUP_MA'
      TYMOCL(2) = 'GROUP_MA'
      MOTCLE(3) = 'MAILLE'
      TYMOCL(3) = 'MAILLE'
C
      NOMJV  = '&&OP0167.LISTE_MA'
      CALL RELIEM(' ', NOMA, 'NO_MAILLE', MCFACT, IOCC, NBMC,
     &                      MOTCLE, TYMOCL, NOMJV, NBMA )
      CALL JEVEUO ( NOMJV, 'L', JNOMA )
C
      DO 30 IM = 0 , NBMA-1
         NOMMAI = ZK8(JNOMA+IM)
         CALL JENONU ( JEXNOM(NOMAMA,NOMMAI), NUMA)
         IF ( NUMA .EQ. 0 ) THEN
            IER = IER + 1
             VALK(1) = NOMMAI
             VALK(2) = NOMA
             CALL U2MESK('E','MODELISA6_10', 2 ,VALK)
         ELSE
            IF ( LNUME ) THEN
               CALL CODENT ( NUME, 'G', KNUME )
               NUME = NUME + 1
               LGM = LXLGUT(KNUME)
               IF ( LGM+LGP .GT. 8 ) CALL U2MESS('F','MODELISA6_11')
               NOMMAI = PRFM(1:LGP)//KNUME
            ELSE
               LGM = LXLGUT(NOMMAI)
               IF ( LGM+LGP .GT. 8 ) THEN
                   VALK (1) = PRFM(1:LGP)//NOMMAI
                   VALK (2) = NOMMAI
                   VALK (3) = PRFM
                   CALL U2MESG('F+','MODELISA9_53',3,VALK,0,0,0,0.D0)
                   IF(LGRPMA) THEN
                     VALK(1) = GRPMA
                     CALL U2MESG('F+','MODELISA9_82',1,VALK,0,0,0,0.D0)
                   ENDIF
                   CALL U2MESG('F','MODELISA9_54',0,' ',0,0,0,0.D0)
              ENDIF
              NOMMAI = PRFM(1:LGP)//NOMMAI
            ENDIF
            DO 32 I = 1 , NBMST
               IF ( ZK8(KLIST+I-1) .EQ. NOMMAI ) GOTO 34
 32         CONTINUE
            NBMST = NBMST + 1
            IF ( NBMST .GT. NBV1 ) THEN
               CALL JUVECA ( NOMVEK , 2*NBMST )
               CALL JUVECA ( NOMVEI , 2*NBMST )
               CALL JEVEUO ( NOMVEI , 'E' , ILIST )
               CALL JEVEUO ( NOMVEK , 'E' , KLIST )
               CALL JELIRA ( NOMVEK , 'LONMAX', NBV1, K1B )
            ENDIF
            ZK8(KLIST+NBMST-1) = NOMMAI
            ZI(ILIST+NBMST-1)  = NUMA
 34         CONTINUE
         ENDIF
 30   CONTINUE
      CALL JEDETR ( NOMJV )
C
      IF ( IER .NE. 0 ) CALL ASSERT(.FALSE.)
C
      CALL JEDEMA ( )
      END
