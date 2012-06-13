      SUBROUTINE NMARCE(SDIETO,RESULT,SDDISC,INSTAN,NUMARC,
     &                  FORCE )
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
      IMPLICIT     NONE
      INCLUDE 'jeveux.h'
      CHARACTER*24 SDIETO
      CHARACTER*8  RESULT
      CHARACTER*19 SDDISC
      INTEGER      NUMARC
      REAL*8       INSTAN
      LOGICAL      FORCE
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGORITHME - ARCHIVAGE )
C
C ARCHIVAGE DES CHAMPS
C
C ----------------------------------------------------------------------
C
C
C IN  SDIETO : SD GESTION IN ET OUT
C IN  RESULT : NOM UTILISATEUR DU CONCEPT RESULTAT
C IN  FORCE  : VRAI SI ON SOUHAITE FORCER L'ARCHIVAGE DE TOUS LES CHAMPS
C IN  SDDISC : SD DISCRETISATION TEMPORELLE
C IN  INSTAN : INSTANT D'ARCHIVAGE
C IN  NUMARC : NUMERO D'ARCHIVAGE
C
C
C
C
      CHARACTER*24 IOINFO
      INTEGER      JIOINF
      INTEGER      NBCHAM
      INTEGER      ICHAM
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- ACCES SD IN ET OUT
C
      IOINFO = SDIETO(1:19)//'.INFO'
      CALL JEVEUO(IOINFO,'L',JIOINF)
      NBCHAM = ZI(JIOINF+1-1)
C
C --- BOUCLE SUR LES CHAMPS
C
      DO 10 ICHAM  = 1,NBCHAM
        CALL NMETEO(RESULT,SDDISC,SDIETO,FORCE ,NUMARC,
     &              INSTAN,ICHAM )
   10 CONTINUE
C
      CALL JEDEMA()
      END
