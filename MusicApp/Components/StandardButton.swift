//
//  Button.swift
//  MusicApp
//
//  Created by Russal Arya on 19/10/2025.
//


Button("Continue") {
                Task { await authorizeAndFetchToken() }
            }
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.customPurple)
            .foregroundColor(.buttonLabel)
            .cornerRadius(12)