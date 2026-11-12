---@meta audio

---@alias SourceType "static" | "stream"

---@class Source
---@field getVolume fun( self: Source ): number
---@field setVolume fun( self: Source, volume: number )
---@field play fun( self: Source )
---@field seek fun( self: Source, offset: number ) only supports Sources of type "stream"
---@field pause fun( self: Source )
---@field stop fun( self: Source )
Source = {}

---@class audio
---@field getVolume fun(): number
---@field setVolume fun( volume: number )
---@field newSource fun( filename: string, type?: SourceType ): Source
---@field play fun( source: Source, ... )
---@field pause fun( ): ( sources: table )
---@field pause fun( source: Source, ... )
local audio = {}

return audio
