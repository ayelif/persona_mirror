-- Migration: Add inner_monologue column to analyses table
ALTER TABLE analyses ADD COLUMN inner_monologue TEXT;
