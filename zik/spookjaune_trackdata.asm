; TIATracker music player
; Copyright 2016 Andre "Kylearan" Wichmann
; Website: https://bitbucket.org/kylearan/tiatracker
; Email: andre.wichmann@gmx.de
;
; Licensed under the Apache License, Version 2.0 (the "License");
; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
;
;   http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS,
; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
; See the License for the specific language governing permissions and
; limitations under the License.

; Song author: Glafouk
; Song name: Spook Jaune

; =====================================================================
; TIATracker melodic and percussion instruments, patterns and sequencer
; data.
; =====================================================================
tt_TrackDataStart:

; =====================================================================
; Melodic instrument definitions (up to 7). tt_envelope_index_c0/1 hold
; the index values into these tables for the current instruments played
; in channel 0 and 1.
; 
; Each instrument is defined by:
; - tt_InsCtrlTable: the AUDC value
; - tt_InsADIndexes: the index of the start of the ADSR envelope as
;       defined in tt_InsFreqVolTable
; - tt_InsSustainIndexes: the index of the start of the Sustain phase
;       of the envelope
; - tt_InsReleaseIndexes: the index of the start of the Release phase
; - tt_InsFreqVolTable: The AUDF frequency and AUDV volume values of
;       the envelope
; =====================================================================

; Instrument master CTRL values
tt_InsCtrlTable:
        dc.b $06, $04, $0c, $04, $0c


; Instrument Attack/Decay start indexes into ADSR tables.
tt_InsADIndexes:
        dc.b $00, $12, $12, $1c, $1c


; Instrument Sustain start indexes into ADSR tables
tt_InsSustainIndexes:
        dc.b $0e, $18, $18, $25, $25


; Instrument Release start indexes into ADSR tables
; Caution: Values are stored with an implicit -1 modifier! To get the
; real index, add 1.
tt_InsReleaseIndexes:
        dc.b $0f, $19, $19, $26, $26


; AUDVx and AUDFx ADSR envelope values.
; Each byte encodes the frequency and volume:
; - Bits 7..4: Freqency modifier for the current note ([-8..7]),
;       8 means no change. Bit 7 is the sign bit.
; - Bits 3..0: Volume
; Between sustain and release is one byte that is not used and
; can be any value.
; The end of the release phase is encoded by a 0.
tt_InsFreqVolTable:
; 0: bassline
        dc.b $8f, $8e, $8e, $8d, $8d, $8c, $8c, $8b
        dc.b $8b, $8a, $8a, $89, $89, $88, $86, $00
        dc.b $80, $00
; 1+2: Lead0
        dc.b $87, $86, $85, $84, $83, $82, $81, $00
        dc.b $80, $00
; 3+4: Accord
        dc.b $88, $58, $37, $86, $55, $34, $83, $52
        dc.b $31, $80, $00, $30, $30, $00



; =====================================================================
; Percussion instrument definitions (up to 15)
;
; Each percussion instrument is defined by:
; - tt_PercIndexes: The index of the first percussion frame as defined
;       in tt_PercFreqTable and tt_PercCtrlVolTable
; - tt_PercFreqTable: The AUDF frequency value
; - tt_PercCtrlVolTable: The AUDV volume and AUDC values
; =====================================================================

; Indexes into percussion definitions signifying the first frame for
; each percussion in tt_PercFreqTable.
; Caution: Values are stored with an implicit +1 modifier! To get the
; real index, subtract 1.
tt_PercIndexes:
        dc.b $01


; The AUDF frequency values for the percussion instruments.
; If the second to last value is negative (>=128), it means it's an
; "overlay" percussion, i.e. the player fetches the next instrument note
; immediately and starts it in the sustain phase next frame. (Needs
; TT_USE_OVERLAY)
tt_PercFreqTable:
; 0: Snare
        dc.b $05, $1b, $08, $05, $05, $07, $0a, $0d
        dc.b $11, $1a, $00


; The AUDCx and AUDVx volume values for the percussion instruments.
; - Bits 7..4: AUDC value
; - Bits 3..0: AUDV value
; 0 means end of percussion data.
tt_PercCtrlVolTable:
; 0: Snare
        dc.b $8f, $cf, $6e, $8c, $8a, $88, $86, $84
        dc.b $82, $80, $00


        
; =====================================================================
; Track definition
; The track is defined by:
; - tt_PatternX (X=0, 1, ...): Pattern definitions
; - tt_PatternPtrLo/Hi: Pointers to the tt_PatternX tables, serving
;       as index values
; - tt_SequenceTable: The order in which the patterns should be played,
;       i.e. indexes into tt_PatternPtrLo/Hi. Contains the sequences
;       for all channels and sub-tracks. The variables
;       tt_cur_pat_index_c0/1 hold an index into tt_SequenceTable for
;       each channel.
;
; So tt_SequenceTable holds indexes into tt_PatternPtrLo/Hi, which
; in turn point to pattern definitions (tt_PatternX) in which the notes
; to play are specified.
; =====================================================================

; ---------------------------------------------------------------------
; Pattern definitions, one table per pattern. tt_cur_note_index_c0/1
; hold the index values into these tables for the current pattern
; played in channel 0 and 1.
;
; A pattern is a sequence of notes (one byte per note) ending with a 0.
; A note can be either:
; - Pause: Put melodic instrument into release. Must only follow a
;       melodic instrument.
; - Hold: Continue to play last note (or silence). Default "empty" note.
; - Slide (needs TT_USE_SLIDE): Adjust frequency of last melodic note
;       by -7..+7 and keep playing it
; - Play new note with melodic instrument
; - Play new note with percussion instrument
; - End of pattern
;
; A note is defined by:
; - Bits 7..5: 1-7 means play melodic instrument 1-7 with a new note
;       and frequency in bits 4..0. If bits 7..5 are 0, bits 4..0 are
;       defined as:
;       - 0: End of pattern
;       - [1..15]: Slide -7..+7 (needs TT_USE_SLIDE)
;       - 8: Hold
;       - 16: Pause
;       - [17..31]: Play percussion instrument 1..15
;
; The tracker must ensure that a pause only follows a melodic
; instrument or a hold/slide.
; ---------------------------------------------------------------------
TT_FREQ_MASK    = %00011111
TT_INS_HOLD     = 8
TT_INS_PAUSE    = 16
TT_FIRST_PERC   = 17

; b+d0a
tt_pattern0:
        dc.b $36, $6e, $ae, $36, $11, $70, $36, $2e
        dc.b $30, $73, $ae, $30, $11, $70, $30, $2e
        dc.b $38, $73, $af, $38, $11, $6e, $38, $38
        dc.b $3e, $70, $ae, $36, $11, $3e, $38, $11
        dc.b $00

; b+d0b
tt_pattern1:
        dc.b $36, $6e, $ae, $36, $11, $6a, $36, $2e
        dc.b $30, $6e, $ae, $30, $11, $70, $30, $2e
        dc.b $2c, $6e, $af, $2c, $11, $6a, $2c, $2e
        dc.b $30, $6e, $ae, $30, $11, $32, $36, $11
        dc.b $00

; b+d0c
tt_pattern2:
        dc.b $08, $6e, $ae, $08, $11, $6a, $08, $6e
        dc.b $70, $6e, $ae, $08, $11, $70, $08, $6e
        dc.b $00

; b+d0c2
tt_pattern3:
        dc.b $08, $6e, $af, $08, $11, $70, $08, $73
        dc.b $08, $6e, $ae, $36, $11, $70, $38, $11
        dc.b $00

; blank
tt_pattern4:
        dc.b $08, $51, $51, $55, $08, $58, $55, $58
        dc.b $00

; blank+meldebut
tt_pattern5:
        dc.b $08, $55, $58, $55, $55, $08, $53, $08
        dc.b $00

; mel0a1
tt_pattern6:
        dc.b $51, $08, $51, $51, $08, $50, $51, $08
        dc.b $55, $08, $4a, $48, $53, $08, $55, $08
        dc.b $00

; mel0a2
tt_pattern7:
        dc.b $58, $08, $5d, $58, $08, $5d, $58, $08
        dc.b $55, $08, $48, $4a, $55, $4a, $53, $08
        dc.b $00

; mel0b
tt_pattern8:
        dc.b $51, $08, $50, $51, $08, $4e, $50, $53
        dc.b $51, $58, $55, $58, $55, $48, $53, $4e
        dc.b $00

; mel1a1
tt_pattern9:
        dc.b $51, $4a, $51, $51, $4e, $50, $51, $4a
        dc.b $55, $4a, $48, $4a, $53, $4e, $55, $4b
        dc.b $00

; mel1a2
tt_pattern10:
        dc.b $58, $4a, $5d, $58, $48, $5d, $58, $4a
        dc.b $55, $4e, $4b, $49, $55, $4a, $53, $48
        dc.b $00

; mel1b
tt_pattern11:
        dc.b $51, $4a, $50, $51, $4e, $4e, $50, $53
        dc.b $51, $58, $55, $58, $55, $48, $53, $4a
        dc.b $00




; Individual pattern speeds (needs TT_GLOBAL_SPEED = 0).
; Each byte encodes the speed of one pattern in the order
; of the tt_PatternPtr tables below.
; If TT_USE_FUNKTEMPO is 1, then the low nibble encodes
; the even speed and the high nibble the odd speed.
    IF TT_GLOBAL_SPEED = 0
tt_PatternSpeeds:
%%PATTERNSPEEDS%%
    ENDIF


; ---------------------------------------------------------------------
; Pattern pointers look-up table.
; ---------------------------------------------------------------------
tt_PatternPtrLo:
        dc.b <tt_pattern0, <tt_pattern1, <tt_pattern2, <tt_pattern3
        dc.b <tt_pattern4, <tt_pattern5, <tt_pattern6, <tt_pattern7
        dc.b <tt_pattern8, <tt_pattern9, <tt_pattern10, <tt_pattern11

tt_PatternPtrHi:
        dc.b >tt_pattern0, >tt_pattern1, >tt_pattern2, >tt_pattern3
        dc.b >tt_pattern4, >tt_pattern5, >tt_pattern6, >tt_pattern7
        dc.b >tt_pattern8, >tt_pattern9, >tt_pattern10, >tt_pattern11
        


; ---------------------------------------------------------------------
; Pattern sequence table. Each byte is an index into the
; tt_PatternPtrLo/Hi tables where the pointers to the pattern
; definitions can be found. When a pattern has been played completely,
; the next byte from this table is used to get the address of the next
; pattern to play. tt_cur_pat_index_c0/1 hold the current index values
; into this table for channels 0 and 1.
; If TT_USE_GOTO is used, a value >=128 denotes a goto to the pattern
; number encoded in bits 6..0 (i.e. value AND %01111111).
; ---------------------------------------------------------------------
tt_SequenceTable:
        ; ---------- Channel 0 ----------
        dc.b $00, $01, $00, $01, $00, $01, $00, $01
        dc.b $02, $03, $02, $03, $80

        
        ; ---------- Channel 1 ----------
        dc.b $04, $04, $04, $04, $04, $04, $04, $05
        dc.b $06, $07, $06, $08, $06, $07, $06, $08
        dc.b $09, $0a, $09, $0b, $09, $0a, $09, $0b
        dc.b $8d


        echo "Track size: ", *-tt_TrackDataStart
