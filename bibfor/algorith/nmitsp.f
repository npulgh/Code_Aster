      SUBROUTINE NMITSP(SDIMPR,SDDISC,ITERAT,RETSUP)
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
      CHARACTER*24 SDIMPR
      CHARACTER*19 SDDISC
      INTEGER      ITERAT,RETSUP
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGORITHME - GESTION DES EVENEMENTS)
C
C GESTION DE L'ACTION ITER_SUPPL
C
C ----------------------------------------------------------------------
C
C
C IN  SDIMPR : SD AFFICHAGE
C IN  SDDISC : SD DISCRETISATION TEMPORELLE
C IN  ITERAT : NUMERO D'ITERATION DE NEWTON
C OUT RETSUP : CODE RETOUR
C               0 ON NE PEUT AJOUTER D'ITERATIONS
C               1 ON FAIT DONC DES ITERATIONS EN PLUS
C
C
C
C
      LOGICAL  LEXTRA
      REAL*8   VALEXT(4),CIBLEN
      INTEGER  ITESUP,NBITAJ,VALI(2),NBITER,MNITER
      REAL*8   R8BID
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      RETSUP = 1
      NBITAJ = 0
      CIBLEN = 0.D0
      LEXTRA = .FALSE.
C
C --- LECTURE DES INFOS SUR LES CONVERGENCES
C
      CALL NMLERR(SDDISC,'L','MNITER',R8BID ,MNITER)
      CALL NMLERR(SDDISC,'L','NBITER',R8BID ,NBITER)
C
C --- AFFICHAGE
C
      IF (ITERAT.GE.NBITER) THEN
        RETSUP = 0
        CALL U2MESI('I','ITERSUPP_2',1,NBITER)
        GOTO 999
      ELSE
        CALL U2MESS('I','ITERSUPP_1')
      ENDIF
C
C --- EXTRAPOLATION LINEAIRE DES RESIDUS
C
      CALL NMACEX(SDDISC,ITERAT,LEXTRA,VALEXT)
C
C --- CALCUL DE LA CIBLE (NOMBRE D'ITERATIONS)
C
      IF (LEXTRA) THEN
        CIBLEN = (VALEXT(1) + VALEXT(2)*LOG(VALEXT(4)) )/VALEXT(3)
        CALL U2MESS('I','EXTRAPOLATION_11')
      ELSE
        CIBLEN = 0.D0
        CALL U2MESS('I','EXTRAPOLATION_10')
        RETSUP = 0
        GOTO 999
      ENDIF
C
C --- NOMBRE D'ITERATIONS SUPPLEMENTAIRES
C
      NBITAJ = NINT(CIBLEN)
C
C --- AFFICHAGE
C
      CALL U2MESI('I','ITERSUPP_3',1,NBITAJ)
C
C --- L'EXTRAPOLATION DONNE UN NOMBRE D'ITERATION < LIMITE ITERATION
C
      IF ( (CIBLEN*1.20D0) .LT. MNITER ) THEN
        RETSUP = 0
        CALL U2MESS('I','ITERSUPP_4')
        GOTO 999
      ENDIF
C
C --- L'EXTRAPOLATION DONNE UN NOMBRE D'ITERATION > LIMITE ITERATION
C
      IF (NBITAJ .GE. NBITER ) THEN
        RETSUP  = 0
        VALI(1) = NBITAJ
        VALI(2) = NBITER
        CALL U2MESI('I','ITERSUPP_5',2,VALI  )
      ENDIF
C
 999  CONTINUE
C
      IF (RETSUP.EQ.1) THEN
        CALL U2MESS('I','ITERSUPP_7')
        CALL AFFICH('MESSAGE',' ')
        CALL NMIMPR(SDIMPR,'IMPR','LIGNE',' ',0.D0,0)
        ITESUP = 1
      ELSEIF (RETSUP.EQ.0) THEN
        CALL U2MESS('I','ITERSUPP_6')
        ITESUP = 0
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF
      CALL NMLERR(SDDISC,'E','ITERSUP',R8BID ,ITESUP)
C
      CALL JEDEMA()
      END
