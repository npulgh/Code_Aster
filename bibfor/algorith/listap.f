      SUBROUTINE LISTAP(MOTFAC,IEXCI ,TYPAPP)
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
C
      IMPLICIT     NONE
      INCLUDE 'jeveux.h'
      CHARACTER*16 MOTFAC
      INTEGER      IEXCI
      CHARACTER*16 TYPAPP
C
C ----------------------------------------------------------------------
C
C ROUTINE UTILITAIRE (LISTE_CHARGES)
C
C TYPE D'APPLICATION DE LA CHARGE
C
C ----------------------------------------------------------------------
C
C
C IN  MOTFAC : MOT-CLEF FACTEUR
C IN  IEXCI  : OCCURRENCE DU MOT-CLEF FACTEUR
C IN  TYPAPP : TYPE D'APPLICATION DE LA CHARGE
C              FIXE_CSTE
C              FIXE_PILO
C              SUIV
C              DIDI
C
C
C
C
      INTEGER EXIMC,GETEXM
      INTEGER N
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
      EXIMC  = GETEXM(MOTFAC,'TYPE_CHARGE')
      IF (EXIMC.EQ.1) THEN
        CALL GETVTX(MOTFAC,'TYPE_CHARGE',IEXCI,1,1,TYPAPP,N)
        CALL ASSERT(N.EQ.1)
      ELSE
        TYPAPP = 'FIXE_CSTE'
      ENDIF
C
      CALL JEDEMA()
      END
